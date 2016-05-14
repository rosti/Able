require 'thread'
require 'concurrent'
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

      @build_loop_lock = Mutex.new
      @task_completed = ConditionVariable.new
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
      output_paths.inject({}) do |all, path|
        task = @all_tasks[path]
        all[path] = task if task
        all
      end
    end

    def task_executed!
      @task_completed.broadcast
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

    def pop_executable_task(tasks_queue)
      @build_loop_lock.synchronize do
        loop do
          return if tasks_queue.empty?

          task_pos = tasks_queue.find_index(&:executable?)
          return tasks_queue.delete_at(task_pos) if task_pos

          @task_completed.wait(@build_loop_lock) if @threads > 1
        end
      end
    end

    def build_thread(tasks_queue)
      loop do
        task = pop_executable_task(tasks_queue)
        break unless task
        task.execute
      end
    end

    def build_queue(tasks_queue)
      Thread.abort_on_exception = true
      thread_handles = []
      @threads.times do
        thread_handles << Thread.new { build_thread(tasks_queue) }
      end

      thread_handles.each(&:join)
    end
  end
end
