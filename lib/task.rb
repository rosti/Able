require 'set'

module Able

  ##
  # Handle execution and evaluation of tasks
  #
  class Task
    attr_reader :target, :in_files

    ##
    # Task constructor
    #
    # The first argument is a Directory object of the holding directory.
    # The second argument is a hash of named arguments
    # with the following symbols defined:
    # * :in_files => An Array of Strings indicating input files
    # * :target   => A String indicating target file
    # * :rule     => A rule that can handle the task
    # * :handler  => A Proc handler to be executed instead of the rule one
    # * :description => A String describing the task
    #
    def initialize dir, args
      @dir = dir
      @in_files     = args[:in_files]
      @target       = args[:target]
      @in_files_abs = @dir.prepend(:src_path, args[:in_files] || [])
      @target_abs   = @dir.prepend(:dst_path, args[:target])[0]
      @rule         = args[:rule]
      @handler      = args[:handler]
      @description  = args[:description]
      @depends      = []
      @executed     = false
    end

    ##
    # Return something to identify the target with
    #
    def name
      @target_abs
    end

    ##
    # Return a string description of target or nil if there is no description
    #
    def describe
      return @description if @description
      return @rule.describe(@in_files, @target) if @rule
    end

    def setup_depends
      @depends = @dir.project.get_tasks_by_name Array(@in_files_abs)
    end

    ##
    # Return true if task was already executed
    #
    def executed?
      @executed
    end

    ##
    # Execute a given task and all of its subtasks
    #
    # Return true if exection was necessary, or false otherwise
    #
    def execute
      return false if @executed
      @executed = true

      execute = false
      @depends.each { |task| execute = true if task.execute }

      do_execute if execute or need_execution?
    end

    private
    
    def need_execution?
      depends = Set.new @in_files_abs
      depends |= Array(@rule.extra_depends(@in_files_abs)) if @rule
      depends.any? { |in_file| File.mtime(in_file) > File.mtime(@target_abs) }
    rescue
      true
    end

    def do_execute
      if @handler
        @handler.(@in_files_abs, @target_abs)
      elsif @rule
        @rule.build @in_files_abs, @target_abs
      end
    end

  end

end

