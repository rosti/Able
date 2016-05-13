require 'concurrent'

module Able
  # Task entity and execution
  class Task
    attr_reader :params

    def initialize(dir, rule, params, description = nil)
      @dir = dir
      @rule = rule
      @params = params
      @description = description
      @dependents = []
      @wait_count = Concurrent::AtomicFixnum.new
      @visited = false

      params.prepend_input_path!(dir.in_dir)
      params.prepend_output_path!(dir.out_dir)
      extra_input_paths = rule.extra_input_paths(params)
      extra_output_paths = rule.extra_output_paths(params)
      params.input_paths += Array(extra_input_paths)
      params.output_paths += Array(extra_output_paths)

      dir.project.add_task(self)
    end

    def add_dependent!(task)
      @dependents << task
    end

    def notify_ready!
      @wait_count.decrement
    end

    def setup_depends!
      project = @dir.project
      src_root = project.src_root
      dst_root = project.dst_root
      depends = project.tasks_by_output(params.retarget_input_paths(src_root, dst_root).map(&:to_s))

      params.input_paths -= depends.keys.map { |path| src_root + path }
      params.input_paths += depends.keys.map { |path| dst_root + path }

      depend_tasks = depends.values
      depend_tasks <<= @dir.task unless @dir.task.equal?(self)
      @wait_count.value = depend_tasks.count
      depend_tasks.each { |task| task.add_dependent!(self) }
    end

    def not_visited?
      !@visited
    end

    def visit!
      @visited = true
    end

    def description
      desc = @description || @rule.description(params)
      desc = "Building: #{params.input_paths.map(&:to_s)} => #{params.output_paths.map(&:to_s)}" unless desc
      desc
    end

    def execute
      if need_execution?
        Logger.info(description)
        @rule.build(params)
      end

      @dependents.each(&:notify_ready!)
      @dir.project.task_executed!
    end

    def executable?
      @wait_count.value.zero?
    end

    def clean
      Logger.info("Cleaning: #{params.output_paths.map(&:to_s)}")
      @rule.clean(params)
    end

    private

    def need_execution?
      params.output_paths.each do |op|
        params.input_paths.each do |ip|
          return true if File.mtime(op.to_s) < File.mtime(ip.to_s)
        end
      end

      params.input_paths.empty?
    rescue
      true
    end
  end
end
