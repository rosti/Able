require 'set'
require 'thread'
require 'pathname'

module Able

  class Project

    attr_accessor :default_target
    attr_reader :all_tasks, :src_root, :dst_root

    def initialize(args = {})
      @all_tasks = {}
      @default_target = "all"
      @threads = args[:threads] || 1
      @src_root = Pathname.new(args[:src_root] || '.')
      @dst_root = Pathname.new(args[:dst_root] || '.')

      Logger.add_logger(ConsoleLogger)

      @root_dir = Directory.new('.', nil, self, @src_root, @dst_root)
      @root_dir.load_buildable
    end

    def add_task(task)
      task.output_paths.map(&:to_s).each do |target|
        if @all_tasks[target]
          raise "Task '#{task}' is duplicting task '#{@all_tasks[target]}' for target '#{target}'"
        end

        @all_tasks[target] = task
      end
    end

    def get_path(subdir, name)
      path = subdir + name
      path = @src_root + name unless path.file?
      path = @dst_root + name unless path.file?

      raise "Cannot find file #{name}" unless path.file?
      path
    end

    def load_logger(name)
      Logger.add_logger(name)
    end

    def build_target(target = nil)
      target = @default_target unless target

      raise "No task '#{target}', nothing to do!" unless @all_tasks[target]

      build_queue(prepare_queue(target))
    end

    def clean(target = nil)
      clean_targets = @all_tasks.values
      clean_targets = prepare_queue(target) if target
      clean_targets.each { |task| task.clean }
    end

  private

    def prepare_queue(target)
      tasks_queue = [@all_tasks[target]]
      tasks_queue[0].visit
      index = 0

      while index < tasks_queue.count
        task = tasks_queue[index]
        in_paths = task.input_paths.map(&:to_s)
        depends = @all_tasks.select { |path, task| in_paths.include?(path) }
        task.dependencies = depends
        tasks_queue |= task.dependencies.select { |task| not(task.visited?) }
        task.dependencies.each(&:visit)
        index += 1
      end

      tasks_queue.reverse
    end

    def build_queue(tasks_array)
      tasks_queue = Queue.new
      tasks_array.each { |task| tasks_queue.push(task) }
      continue_work = Atomic.new(true)
      thread_handles = []
      @threads.times do
        thread_handles << Thread.new do
          begin
            while continue_work.get
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
          rescue Exception => ex
            continue_work.set(false)
            Logger.error(ex.to_s + "\n" + ex.backtrace.join("\n"))
          end
        end
      end

      thread_handles.each(&:join)
    end

  end
end
