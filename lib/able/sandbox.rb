module Able

  class ConfigBox
    include Common

    def initialize(directory, prefix)
      @directory = directory
      @prefix = prefix
    end

    def rule(name, rule_obj)
      @directory.add_rule(name, rule_obj, @prefix)
    end
  end

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

    def task(*flags, target, &block)
      in_files = nil
      out_files = target

      begin
        in_files = target.keys.first
        out_files = target.values.first
      rescue
      end

      @directory.add_task(@last_description, flags, in_files, out_files, self, &block)
    end

    def build(rule, *flags, target)
      in_files = nil
      out_files = target

      begin
        in_files = target.keys.first
        out_files = target.values.first
      rescue
      end

      @directory.add_build(@last_description, rule, flags, in_files, out_files)
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
      @directory.set_default_target(target)
    end

    def project_targets()
      @directory.project_targets
    end

  end

end
