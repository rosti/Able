module Able

  ##
  # The module that covers the Able DSL. This module must be included in class SubDir
  module AbleDSL

    ##
    # Setup a default target name for this subdirectory.
    # It takes only one argument, which is String or Symbol containing the target name.
    #
    def default target_name
      self.default_target = target_name.to_s
    end

    ##
    # Takes an Array of subdirectory names (as Strings or Symbols) and passes them to
    # the build system for interpretation of build.able files in them.
    #
    def subdirs *args, &block
      args.flatten.each { |dir| subdir dir, &block }
    end

    ##
    # Create a subdirectory object by a given subdirectory name (as String or Symbol)
    #
    def subdir dir_name
      add_subdir dir_name unless @subdirs.keys.include? dir_name
    rescue
      unless block_given?
        Logger.log "Unable to load '#{dir_name}/build.able' file!"
        raise
      end
    ensure
      yield dir_name if block_given?
      @subdirs[dir_name]
    end

    ##
    # Setup a short description string for next task.
    # This function takes one String argument that is the description.
    #
    def desc str
      Logger.log "Warning: Another description detected: '#{@last_desc}'" if @last_desc
      @last_desc = str.to_s
    end

    ##
    # Setup a rule
    #
    def rule identify, &block
      create_rule identify, block
    end

    ##
    # Build multiple tasks by given sources list and/or hash pairs
    #
    def build *args, &block
      args.flatten.each do |arg|
        if arg.instance_of? Hash
          arg.each { |source, target|  create_task source, target, &block }
        else
          create_task arg, nil, &block
        end
      end
    end

    ##
    # Build a single chaining task
    #
    def task arg, &block
      if arg.instance_of? Hash
        create_task *Array(arg)[0], &block
      else
        create_task nil, arg, &block
      end
    end

    ##
    # Register or ammend configuration
    # Takes a single argument that is the configuration name (in String or Symbol)
    #
    def config name, &block
      cfg = begin
        project.get_config name
      rescue
        Configuration.new name
      end

      cfg.instance_eval &block if block
      project.add_config cfg
    end

    ##
    # Setup various aspects of the project environment
    # Takes a hash with the following pair values:
    # [:config] => Configuration name (as String or Symbol)
    # [:logger] => Logger name (as String or Symbol)
    #
    def use args
      use_config args[:config] if args[:config]
      Logger.use_logger args[:logger] if args[:logger]
    end

    ##
    # Setup a output directory for the output of the current subdirectory
    # Input is a one String value indicating the path to the new output directory.
    # If a relative path is given, than the new path is based on the current one.
    #
    def output_dir path
      self.dst_path = dst_path.join path
      self.dir_task.set_target '' # force rebuilding of dir_task target path
    end

  end

end

