require 'set'

module Able
  # Task entity and execution
  class Task
    attr_reader :dependencies

    def initialize(dir, rule, flags, in_files, out_files, description = nil)
      @dir = dir
      @rule = rule
      @flags = flags
      @input_files = in_files
      @output_files = out_files
      @description = description
      @dependencies = Set.new(dir.parent && [dir.parent.task])
      @executed = false
      @visited = false

      @input_paths = @input_files.map { |file| @dir.in_dir + file }
      @output_paths = @output_files.map { |file| @dir.out_dir + file }
      extra_input_paths = rule.extra_input_paths(@input_paths, @output_paths, @flags)
      extra_output_paths = rule.extra_output_paths(@input_paths, @output_paths, @flags)
      @input_paths += Array(extra_input_paths)
      @output_paths += Array(extra_output_paths)

      dir.project.add_task(self)
    end

    def dependencies=(new_deps)
      @dependencies |= new_deps.values
      in_path_deps = new_deps.keys.map { |path| @dir.project.src_root + path }
      out_path_deps = new_deps.keys.map { |path| @dir.project.dst_root + path }
      @input_paths = (@input_paths - in_path_deps) + out_path_deps
    end

    def input_paths
      canonize_paths(@input_paths, @dir.project.src_root)
    end

    def output_paths
      canonize_paths(@output_paths, @dir.project.dst_root)
    end

    def visited?
      @visited
    end

    def visit
      @visited = true
    end

    def description
      desc = @description
      desc = @rule.description(@input_paths, @output_paths, @flags) unless desc
      desc = "Building: #{@input_paths.map(&:to_s)} => #{@output_paths.map(&:to_s)}" unless desc
      desc
    end

    def execute
      fail "Attempt to execute task '#{description}' again" if executed?
      fail "Task '#{description}' is not yet executable!" unless executable?

      if need_execution?
        Logger.info(description)
        @rule.build(@input_paths, @output_paths, @flags)
      end

      @executed = true
    end

    def executed?
      @executed
    end

    def executable?
      @dependencies.all?(&:executed?)
    end

    def clean
      Logger.info("Cleaning: #{@output_paths.map(&:to_s)}")
      @rule.clean(@input_paths, @output_paths, @flags)
    end

    private

    def need_execution?
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
