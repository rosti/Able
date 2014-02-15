module Able

  class Directory

    def initialize(name, parent, project, in_dir, out_dir)
      @name = name
      @parent = parent
      @project = project
      @in_dir = in_dir + name
      @out_dir = out_dir + name
      @subdirs = {}
      @rules = {}
      @task = Task.new(project, project.find_rule(:mkdir, []), [], [], [name], in_dir, out_dir, nil, nil)
      @project.add_task(@task)
    end

    def root_dir?
      @parent == nil
    end

    def add_rule(name, type, &block)
      rule = Rule.new
      rule.instance_eval(&block)

      case type
      when :local
        raise "Local rules cannot contain '_' in their names" if name.to_s.include?("_")
        @rules[name] = rule
      when :global
        project.add_rule(name, rule)
      end
    end

    def add_task(description, flags, in_files, out_files, &block)
      task = Task.new(@project, NamelessRule.new(block), Array(flags), Array(in_files), Array(out_files), @in_dir, @out_dir, [@task], description)
      @project.add_task(task)
    end

    def add_build(description, rule, flags, in_files, out_files)
      task = Task.new(@project, find_rule(rule), Array(flags), Array(in_files), Array(out_files), @in_dir, @out_dir, [@task], description)
      @project.add_task(task)
    end

    def load_buildable(build_able = "build.able", &block)
      sandbox = BuildBox.new(self)
      build_able_path = @in_dir + build_able
      build_able_contents = nil

      begin
        build_able_contents = File.read(build_able_path)
      rescue
      end

      sandbox.instance_eval(build_able_contents, build_able_path.to_s) if build_able_contents
      sandbox.instance_eval(&block) if block
    end

    def add_subdir(name, &block)
      return if @subdirs[name]

      subdir = Directory.new(name.to_s, self, @project, @in_dir, @out_dir)
      subdir.load_buildable

      @subdirs[name] = subdir
    end

    def load_config(config)
      @project.load_config(config)
    end

    def load_logger(logger)
      @project.load_logger(logger)
    end

    def project_targets()
      @project.all_tasks.keys
    end

    def set_default_target(target)
      @project.default_target = target if root_dir?
    end

  private
    
    def find_rule(rule_name)
      rule_split = rule_name.to_s.split("_").map(&:to_sym)
      name = rule_split.last
      tags = rule_split[0...-1]
      rule = @rules[rule_name]
      raise "No local rule #{rule_name} found!" if not(rule) and tags.include?(:local)
      rule = @project.find_rule(name, tags) unless rule
    end

  end

end
