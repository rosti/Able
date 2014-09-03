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
      @sandbox = BuildBox.new(self)
      @task = Task.new(project, find_rule(:mkdir), [], [], [name], in_dir, out_dir, nil, nil)
      @project.add_task(@task)
    end

    def root_dir?
      @parent == nil
    end

    def add_task(description, flags, in_files, out_files, sandbox, &block)
      task = Task.new(@project, BasicRule.new(block),
                      Array(flags), Array(in_files), Array(out_files),
                      @in_dir, @out_dir, [@task], description)
      @project.add_task(task)
    end

    def add_build(description, rule, flags, in_files, out_files)
      task = Task.new(@project, find_rule(rule),
                      Array(flags), Array(in_files), Array(out_files),
                      @in_dir, @out_dir, [@task], description)
      @project.add_task(task)
    end

    def load_buildable(build_able = "build.able", &block)
      build_able_path = @in_dir + build_able
      build_able_contents = nil

      begin
        build_able_contents = File.read(build_able_path)
      rescue
      end

      @sandbox.instance_eval(build_able_contents, build_able_path.to_s) if build_able_contents
      @sandbox.instance_eval(&block) if block
    end

    def add_subdir(name, &block)
      return if @subdirs[name]

      subdir = Directory.new(name.to_s, self, @project, @in_dir, @out_dir)
      subdir.load_buildable

      @subdirs[name] = subdir
    end

    def load_config(name, prefix)
      path = @project.get_path(@in_dir, "#{name}.config", :configs).to_s
      configbox = ConfigBox.new(self, prefix)
      configbox.instance_eval(File.read(path), path)
    end

    def add_rule(name, rule_obj, prefix = nil)
      rule_name = prefix ? "#{prefix}_#{name}".to_sym : name.to_sym
      @rules[rule_name] = rule_obj
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

    def find_rule(rule_name)
      rule = @rules[rule_name.to_sym]
      rule = @parent.find_rule(rule_name) if not rule and @parent
      rule = Base::Rules[rule_name.to_sym] unless rule
      raise "No config rule '#{rule_name}' found!" unless rule
      rule
    end

  end

end
