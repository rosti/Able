module Able

  class Directory

    def initialize(name, parent, project, in_dir, out_dir)
      @name = name
      @parent = parent
      @project = project
      @in_dir = in_dir + name
      @out_dir = out_dir + name
      @subdirs = {}
      @rule_sets = [] # Rules loaded from configurations
      @local_rules = {} # Rules loaded outside configurations
      @sandbox = BuildBox.new(self)
      load_defconfig
      @task = Task.new(project, find_rule(:mkdir), [], [], [name], in_dir, out_dir, nil, nil)
      @project.add_task(@task)
    end

    def root_dir?
      @parent == nil
    end

    def add_task(description, flags, in_files, out_files, sandbox, &block)
      task = Task.new(@project, NamelessRule.new(sandbox, block),
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

    def load_config_from(path, tags)
      @rule_set = RuleSet.new(tags)

      @sandbox.instance_eval(File.read(path), path)

      @rule_sets.insert(0, @rule_set)
      @rule_set = nil
    end

    def load_defconfig()
      load_config_from(File.join(__dir__, "defconfig.rb"), [:default])
    end

    def load_config(name)
      tags = Pathname.new(name.to_s).basename(".able").to_s.split('_')
      path = @project.get_path(@in_dir, name).to_s
      load_config_from(path, tags)
    end

    def add_tag(tag)
      Logger.warn "Tags can only be placed in configs. Tag #{tag} skipped!" unless @rule_set
      @rule_set.add_tag(tag) if @rule_set
    end

    def add_rule(sandbox, name, &block)
      new_rule = Rule.new(sandbox)
      new_rule.instance_eval(&block)

      if @rule_set
        @rule_set.add_rule(name, new_rule)
      else
        @local_rules[name] = new_rule
      end
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
      tags = Set.new(rule_split[0...-1])

      rule = @local_rules[rule_name]
      raise "No local rule '#{rule_name}' found!" if not rule and tags.include?(:local)

      rule = @rule_sets.find { |rule_set| rule_set.get_rule(name, tags) }.get_rule(name) unless rule
      raise "No config rule '#{rule_name}' with tags '#{tags.to_a}' found!" unless rule

      rule
    end

  end

end
