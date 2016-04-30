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
      @directory.load_logger(name)
    end

    def default(target)
      @directory.default_target(target)
    end

    def project_targets
      @directory.project_targets
    end
  end
end
