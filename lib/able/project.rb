require 'set'
require 'thread'
require 'pathname'

module Able

  class Project

    attr_accessor :default_target
    attr_reader :all_tasks, :src_root, :dst_root

    def initialize(args = {})
      @all_tasks = {}
      @rule_sets = []
      @global_rules = {}
      @default_target = "all"
      @threads = args[:threads] || 1
      @src_root = Pathname.new(args[:src_root] || '.')
      @dst_root = Pathname.new(args[:dst_root] || '.')

      Logger.add_logger(ConsoleLogger)
      load_default_config

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

    def add_rule(name, rule)
      raise "Global rules cannot contain '_' in their names" if name.to_s.include?("_")
      global_rules[name] = rule
    end

    def find_rule(name, tags)
      rule = @global_rules[name]
      raise "No global rule '#{name}'" if tags.include?(:global)

      tag_set = Set.new(tags)

      rule = @rule_sets.find { |rule_set| rule_set.get_rule(name, tag_set) } unless rule
      raise "No rule named '#{name}', containing tags: '#{tag_set.to_a}'" unless rule

      rule
    end

    def load_config(name)
      tags = Pathname.new(name.to_s).basename(".able").to_s.split('_')
      rule_set = RuleSet.new(tags)

      sandbox = ConfigBox(rule_set)
      sandbox.load_contents(name.to_s)

      @rule_sets.insert(0, rule_set)
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

    def load_default_config()
      rule_set = RuleSet.new([:default])

      sandbox = ConfigBox.new(rule_set)
      defconfig = File.dirname(__FILE__) + "/defconfig.rb"
      sandbox.instance_eval(File.read(defconfig), defconfig)

      @rule_sets.insert(0, rule_set)
    end

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
