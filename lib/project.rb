module Able

  ##
  # A class that handles all project stuff and provides
  # official interface to the program.
  #
  class Project
    attr_reader :root_dir

    def initialize args = {}
      @tasks = {}
      @configs = {}
      @loggers = {}

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

    def add_logger logger
      @loggers[logger.name] = logger
    end

    def use_logger name
      if name
        $ABLE_LOGGER = @loggers.fetch name.to_s
      else
        $ABLE_LOGGER = nil
      end
    rescue
      raise "Unknown logger: #{name}"
    end

    def get_config name
      @configs.fetch name.to_s
    end

    def do_task name = nil
      name = @root_dir.default_target unless name
      @tasks[name].execute
    end

    def get_tasks_by_name names_array
      @tasks.values_at(*names_array).select { |entry| entry }
    end

    def bind_tasks
      @tasks.each_value { |task| task.setup_depends }
    end
  end

end
