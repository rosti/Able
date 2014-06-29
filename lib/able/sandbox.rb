module Able

  class BuildBox
    include Common

    def initialize(directory)
      @directory = directory
      @last_description = nil
    end

    def desc(text)
      if @last_description
        Logger.warn("Overriding previous description '#{@last_description}' with a new one '#{text}'")
      end
      @last_description = text
    end

    def rule(name, &block)
      @directory.add_rule(self, name, &block)
    end

    def tag(name)
      @directory.add_tag(name)
    end

    def tags(*names)
      names.each { |t| tag(t) }
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

    def config(name)
      @directory.load_config(name)
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
