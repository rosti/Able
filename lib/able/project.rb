require 'thread'
require 'pathname'

module Able
  # Project controller
  class Project
    attr_accessor :default_target
    attr_reader :all_tasks, :src_root, :dst_root

    def initialize(args = {})
      @all_tasks = {}
      @default_target = 'all'
      @threads = args[:threads] || 1
      @src_root = Pathname.new(args[:src_root] || '.')
      @dst_root = Pathname.new(args[:dst_root] || '.')

      Logger.add_logger(ConsoleLogger.new)

      @root_dir = Directory.new('.', nil, self, @src_root, @dst_root)
    end

    def add_task(task)
      task.params.output_paths.map(&:to_s).each do |target|
        if @all_tasks[target]
          fail "Task '#{task}' is duplicting task '#{@all_tasks[target]}' for target '#{target}'"
        end

        @all_tasks[target] = task
      end
    end

    def get_path(subdir, name, type = nil)
      path = subdir + name
      path = @src_root + name unless path.file?
      path = @dst_root + name unless path.file?
      unless path.file?
        path = Pathname.new(__dir__) + type.to_s
        path += name
      end

      fail "Cannot find file #{name}" unless path.file?
      path
    end

    def load_logger(name)
      Logger.add_logger(name)
    end

    def build_target(target = nil)
      target_path = (dst_root+(target||default_target)).to_s

      fail "No task '#{target_path}', nothing to do!" unless @all_tasks[target_path]

      build_queue(prepare_queue(target_path))
    end

    def clean(target = nil)
      clean_targets = @all_tasks.values
      clean_targets = prepare_queue((dst_root+target).to_s) if target
      clean_targets.each(&:clean)
    end

    def tasks_by_output(output_paths)
      output_paths.map { |path| [path, @all_tasks[path]] }.select { |a| a[1] }.to_h
    end

    private

    def prepare_queue(target_path)
      tasks_queue = [@all_tasks[target_path]]
      tasks_queue[0].visit!
      index = 0

      while index < tasks_queue.count
        task = tasks_queue[index]
        depends = task.setup_depends!.select(&:not_visited?)
        tasks_queue |= depends
        depends.each(&:visit!)
        index += 1
      end

      tasks_queue.reverse
    end

    def build_queue(tasks_array)
      tasks_queue = Queue.new
      tasks_array.each { |task| tasks_queue.push(task) }
      thread_handles = []
      Thread.abort_on_exception = true
      @threads.times do
        thread_handles << Thread.new do
          while true
            task = nil
            begin
              task = tasks_queue.pop(true)
            rescue
            end

            break unless task

            if task.executable?
              task.execute
            else
              tasks_queue.push(task)
            end
          end
        end
      end

      thread_handles.each(&:join)
    end
  end
end
