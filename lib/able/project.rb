module Able

  ##
  # A class that handles all project stuff and provides
  # official interface to the program.
  #
  class Project
    include AbleCommon

    attr_reader :root_dir

    def initialize args = {}
      @tasks = {}
      @configs = {}

      src_path = Pathname.new(args[:src_path] ? args[:src_path] : '.')
      dst_path = args[:dst_path] ? Pathname.new(args[:dst_path]) : src_path

      @root_dir = SubDir.new( self, nil, src_path.to_s,
                              src_path: src_path, dst_path: dst_path )

      @root_dir.instance_eval &ABLE_DEFAULT_CONFIG
      @root_dir.load_buildable_file 'build.able'
    end

    def add_task task
      @tasks[task.name] = task
    end

    def add_config config
      @configs[config.name] = config
    end

    def get_config name
      @configs.fetch name.to_s
    end

    def do_task name = nil
      name = @root_dir.default_target unless name
      @tasks[name].execute
    end

    def tasks_and_input_by_name names_array
      tasks = []
      in_files_abs = []

      names_array.each do |name|
        task = @tasks[name]
        if task
          tasks << task
          in_files_abs << task.target_abs
        else
          in_files_abs << name
        end
      end

      return tasks, in_files_abs
    end

    def bind_tasks
      @tasks.each_value { |task| task.setup_depends }
    end
  end

end
