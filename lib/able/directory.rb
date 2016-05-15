module Able
  # Deal with project directory, its tasks and etc.
  class Directory
    attr_accessor :config, :project, :in_dir, :out_dir, :task, :parent

    def initialize(name, parent, project, in_dir, out_dir)
      @name = name
      @parent = parent
      @project = project
      @in_dir = in_dir + name
      @out_dir = out_dir + name
      @subdirs = {}
      @rules = {}
      @config = Configuration.new(parent ? parent.config : nil)
      @sandbox = BuildBox.new(self)

      setup_task
      load_buildable
    end

    def root_dir?
      @parent.nil?
    end

    def add_rule(name, rule_class)
      @rules[name.to_sym] = rule_class
    end

    def add_basic_rule(name, block)
      add_rule(name, build_basic_rule(block))
    end

    def add_task(description, build_args, &block)
      rule = build_basic_rule(block).new(config)
      params = Task::Params.new(self, build_args)
      Task.new(self, rule, params, description)
    end

    def add_build(description, rule, build_args)
      build_rule = find_rule(rule).new(config)
      params = Task::Params.new(self, build_args)
      params.output_paths += build_rule.make_output_files(params.input_paths) if params.output_paths.empty?
      Task.new(self, build_rule, params, description)
    end

    def add_subdir(name)
      @subdirs[name] ||= Directory.new(name.to_s, self, @project, @in_dir, @out_dir)
    end

    def load_config(filename)
      config.merge_from_file!(filename)
    end

    def load_toolset(name)
      ToolBox.new(self, @project.get_path(@in_dir, "#{name}.toolset", :toolsets))
    end

    def project_targets
      @project.all_tasks.keys
    end

    def default_target(target)
      @project.default_target = target if root_dir?
    end

    def find_local_or_base_rule(rule_sym)
      rule = @rules[rule_sym]
      rule = @parent.find_local_or_base_rule(rule_sym) if not rule and @parent
      rule
    end

    def find_rule(rule_name)
      rule = find_local_or_base_rule(rule_name.to_sym)
      fail "No config rule '#{rule_name}' found!" unless rule
      rule
    end

    private

    def setup_task
      task_params = Task::Params.new(self, [])
      task_params.output_paths += [@name]
      @task = Task.new(parent || self, Base::Mkpath.new(config), task_params)
    end

    def load_buildable
      build_able_path = @in_dir + 'build.able'
      @sandbox.instance_eval(File.read(build_able_path), build_able_path.to_s) if File.readable?(build_able_path)
    end

    def build_basic_rule(block)
      Class.new(Rule) { define_method(:build, block) }
    end
  end
end
