require 'pathname'
require 'fileutils'

module Able

  ##
  # This class deals with project subdirectories
  #
  class SubDir
    include AbleCommon
    include AbleDSL

    attr_reader :name, :src_path, :project, :dir_task
    attr_accessor :default_target, :dst_path

    def initialize project, parent_dir, name, args = {}
      @project = project
      @parent_dir = parent_dir
      @name = name.to_s
      @config = parent_dir.get_config if parent_dir
      @src_path = args[:src_path] ? args[:src_path] : parent_dir.src_path.join(name)
      @dst_path = args[:dst_path] ? args[:dst_path] : parent_dir.dst_path.join(name)
      @subdirs = {}
      @tasks = []
      create_dir_task
    end

    def get_config
      @config
    end

    def prepend path_symbol, args
      path = instance_variable_get('@' + path_symbol.to_s)
      Array(args).map { |file| path.join(file).to_s }
    end

    def load_buildable_file file_name
      buildable_filepath = prepend(:src_path, file_name)[0]
      instance_eval File.read(buildable_filepath), buildable_filepath
    end

    def use_config config_name
      @config = project.get_config config_name
    rescue
      raise "Unknown configuration: #{config_name}"
    end

    private

    attr_accessor :last_desc

    def add_subdir dir_name
      dir = SubDir.new @project, self, dir_name
      dir.load_buildable_file 'build.able'
      @subdirs[dir_name] = dir
    end

    def create_rule identify, block
      rule = Rule.new identify
      rule.instance_eval &block
      @config << rule
    end

    def create_task in_files, out_files, &block
      rule = @config.find_rule_by input: Array(in_files)[0], output: Array(out_files)[0]

      if in_files and not out_files
        begin
          out_files = rule.get_target(Array(in_files)[0])
        rescue
          raise 'Anonymous task and no matching rule'
        end
      end

      task = Task.new( self,
                       in_files: Array(in_files).map(&:to_s), target: out_files.to_s,
                       rule: rule, handler: block, description: last_desc,
                       depends: [@dir_task] )

      last_desc = nil

      @tasks << task
      @project.add_task task
    end

    def create_dir_task
      handler = Proc.new do |in_files, target|
        FileUtils.makedirs target unless File.exists? target
      end

      parent_dir_task = @parent_dir ? Array(@parent_dir.dir_task) : nil

      @dir_task = Task.new( self, target: '', handler: handler,
                            description: "Entering directory #{@src_path}",
                            depends: parent_dir_task )
      @tasks << @dir_task
      @project.add_task @dir_task
    end

  end

end
