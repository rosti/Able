require 'set'

module Able
  # Task entity and execution
  class Task
    attr_reader :dependencies, :params

    def initialize(dir, rule, params, description = nil)
      @dir = dir
      @rule = rule
      @params = params
      @description = description
      @dependencies = Set.new(dir.parent && [dir.parent.task])
      @executed = false
      @visited = false

      params.prepend_input_path!(dir.in_dir)
      params.prepend_output_path!(dir.out_dir)
      extra_input_paths = rule.extra_input_paths(params)
      extra_output_paths = rule.extra_output_paths(params)
      params.input_paths += Array(extra_input_paths)
      params.output_paths += Array(extra_output_paths)

      dir.project.add_task(self)
    end

    def dependencies=(new_deps)
      @dependencies |= new_deps.values
      params.input_paths -= new_deps.keys.map { |path| @dir.project.src_root + path }
      params.input_paths += new_deps.keys.map { |path| @dir.project.dst_root + path }
    end

    def visited?
      @visited
    end

    def visit
      @visited = true
    end

    def description
      desc = @description || @rule.description(params)
      desc = "Building: #{params.input_paths.map(&:to_s)} => #{params.output_paths.map(&:to_s)}" unless desc
      desc
    end

    def execute
      fail "Attempt to execute task '#{description}' again" if executed?
      fail "Task '#{description}' is not yet executable!" unless executable?

      if need_execution?
        Logger.info(description)
        @rule.build(params)
      end

      @executed = true
    end

    def executed?
      @executed
    end

    def executable?
      @dependencies.all?(&:executed?)
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
