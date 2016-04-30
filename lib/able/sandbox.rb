module Able
  # Sandbox environment for configurations
  class ConfigBox
    include Common

    def initialize(directory, prefix)
      @directory = directory
      @prefix = prefix
    end

    def rule(name, rule_obj)
      @directory.add_rule(@prefix ? "#{@prefix}_#{name}" : name, rule_obj)
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
      @directory.add_rule(name, BasicRule.new(block))
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

    def config(name, prefix = nil)
      @directory.load_config(name, prefix)
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
