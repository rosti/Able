require 'set'

module Able

  class Task

    attr_reader :dependencies

    def initialize(project, rule, flags, in_files, out_files, in_dir, out_dir, depends, description)
      @project = project
      @rule = rule
      @flags = flags
      @input_files = in_files
      @output_files = out_files
      @input_dir = in_dir
      @output_dir = out_dir
      @description = description
      @dependencies = Set.new(depends)
      @executed = false
      @visited = false

      @input_paths = @input_files.map { |file| @input_dir + file }
      @output_paths = @output_files.map { |file| @output_dir + file }
      extra_input_paths = rule.extra_input_paths(@input_paths, @output_paths, @flags)
      extra_output_paths = rule.extra_output_paths(@input_paths, @output_paths, @flags)
      @input_paths += Array(extra_input_paths)
      @output_paths += Array(extra_output_paths)
    end

    def dependencies=(new_deps)
      @dependencies |= new_deps.values
      in_path_deps = new_deps.keys.map { |path| @project.src_root + path }
      out_path_deps = new_deps.keys.map { |path| @project.dst_root + path }
      @input_paths = (@input_paths - in_path_deps) + out_path_deps
    end

    def input_paths
      canonize_paths(@input_paths, @project.src_root)
    end

    def output_paths
      canonize_paths(@output_paths, @project.dst_root)
    end

    def visited?()
      @visited
    end

    def visit()
      @visited = true
    end

    def description()
      desc = @description
      desc = @rule.description(@input_paths, @output_paths, @flags) unless desc
      desc = "#{@input_paths.map(&:to_s).to_s} => #{@output_paths.map(&:to_s).to_s}" unless desc
    end

    def execute()
      raise "Attempt to execute task '#{description}' again" if executed?
      raise "Task '#{description}' is not yet executable!" unless executable?

      if need_execution?
        Logger.info("Building: #{description}")
        @rule.build(@input_paths, @output_paths, @flags)
      end

      @executed = true
    end

    def executed?()
      @executed
    end

    def executable?()
      @dependencies.all? { |task| task.executed? }
    end

    def clean
      Logger.info("Cleaning: #{@output_paths.map(&:to_s)}")
      @rule.clean(@input_paths, @output_paths, @flags)
    end

  private
    def need_execution?()
      @output_paths.each do |op|
        @input_paths.each do |ip|
          return true if File.mtime(op.to_s) < File.mtime(ip.to_s)
        end
      end

      @input_paths.empty?
    rescue
      true
    end

    def canonize_paths(paths, base)
      paths.map do |path|
        begin
          path.relative_path_from(base)
        rescue
          path
        end
      end
    end

  end

end

