module Able
  # Deal with project directory, its tasks and etc.
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
      @parent.nil?
    end

    def add_task(description, build_args, &block)
      flags, in_files, out_files = fix_build_args(build_args)
      task = Task.new(@project, BasicRule.new(block),
                      flags, in_files, Array(out_files),
                      @in_dir, @out_dir, [@task], description)
      @project.add_task(task)
    end

    def add_build(description, rule, build_args)
      build_rule = find_rule(rule)
      flags, in_files, out_files = fix_build_args(build_args)
      task = Task.new(@project, build_rule, flags, in_files,
                      Array(out_files || build_rule.make_output_files(in_files)),
                      @in_dir, @out_dir, [@task], description)
      @project.add_task(task)
    end

    def load_buildable(build_able = 'build.able', &block)
      build_able_path = @in_dir + build_able
      build_able_contents = nil

      begin
        build_able_contents = File.read(build_able_path)
      rescue
      end

      @sandbox.instance_eval(build_able_contents, build_able_path.to_s) if build_able_contents
      @sandbox.instance_eval(&block) if block
    end

    def add_subdir(name)
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

    def add_rule(name, rule_obj)
      @rules[name.to_sym] = rule_obj
    end

    def load_logger(logger)
      @project.load_logger(logger)
    end

    def project_targets
      @project.all_tasks.keys
    end

    def default_target(target)
      @project.default_target = target if root_dir?
    end

    def find_rule(rule_name)
      rule = @rules[rule_name.to_sym]
      rule = @parent.find_rule(rule_name) if not rule and @parent
      rule = Base::RULES[rule_name.to_sym] unless rule
      fail "No config rule '#{rule_name}' found!" unless rule
      rule
    end

    private

    def fix_build_args(args)
      last_arg = args.last
      in_files, out_files = nil, nil
      extra_opts = {}

      if last_arg.is_a? Hash
        in_files = last_arg.delete(:input)
        out_files = last_arg.delete(:output)
        unless in_files or out_files
          in_files = last_arg.keys.last
          out_files = last_arg.delete(in_files)
        end
        extra_opts = last_arg
      else
        in_files = last_arg
      end

      hashes = args[0...-1].select { |opt| opt.is_a?(Hash) }.inject({}) { |a, b| a.merge(b) }
      flags = args[0...-1].select { |opt| not opt.is_a?(Hash) }.map { |opt| [opt, true] }.to_h
      return flags.merge(hashes).merge(extra_opts), Array(in_files), out_files
    end
  end
end
