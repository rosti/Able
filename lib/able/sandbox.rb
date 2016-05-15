module Able
  # Sandbox environment for configurations
  class ToolBox
    include Common

    def initialize(directory, path)
      @directory = directory
      instance_eval(File.read(path), path.to_s)
    end

    def rule(name, rule_class)
      @directory.add_rule(name, rule_class)
    end
  end

  # Sandbox environment for build files
  class BuildBox
    include Common

    def initialize(directory)
      @directory = directory
      @last_description = nil
    end

    def rule(name, &block)
      @directory.add_basic_rule(name, block)
    end

    def desc(text)
      if @last_description
        Logger.warn("Overriding previous description '#{@last_description}' with a new one '#{text}'")
      end
      @last_description = text
    end

    def task(*args, &block)
      @directory.add_task(@last_description, args, &block)
    end

    def build(rule, *args)
      @directory.add_build(@last_description, rule, args)
    end

    def subdir(name, &block)
      @directory.add_subdir(name, &block)
    end

    def subdirs(*names)
      names.each { |name| subdir(name) }
    end

    def config(filename)
      @directory.load_config(filename)
    end

    def toolset(name)
      @directory.load_toolset(name)
    end

    def logger(name)
      Logger.load_logger(name)
    end

    def default(target)
      @directory.default_target(target)
    end

    def project_targets
      @directory.project_targets
    end

    def config_value(key)
      @directory.config[key]
    end

    def config_setting(key, value)
      @directory.config[key] = value
    end

    def config_options(key, *opts)
      @directory.config.add_option!(key, opts)
    end

    def config_pairs(key, *options)
      @directory.config.add_pairs!(key, options)
    end

    def include_dir(*dirs)
      config_options(:inc_dirs, *dirs)
    end

    def include_file(*files)
      config_options(:inc_files, *files)
    end

    def lib_dir(*dirs)
      config_options(:lib_dirs, *dirs)
    end

    def link_lib(*libraries)
      config_options(:link_libs, *libraries)
    end

    def cflags(*flags)
      config_options(:cflags, *flags)
    end

    def cxxflags(*flags)
      config_options(:cxxflags, *flags)
    end

    def ldflags(*flags)
      config_options(:ldflags, *flags)
    end

    def defines(*options)
      config_pairs(:defines, *options)
    end
  end
end
