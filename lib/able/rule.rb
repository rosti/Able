require 'set'

module Able

  class Rule
    include Common

    def build(input_paths, output_paths, flags) end

    def description(input_paths, output_paths, flags) end

    def extra_input_paths(input_paths, output_paths, flags) end

    def extra_output_paths(input_paths, output_paths, flags) end

    def clean(input_paths, output_paths, flags)
      unless flags.include?(:no_clean)
        file_paths = output_paths.select do |path|
          File.exists?(path) and not(File.directory?(path))
        end

        File.delete(*file_paths) unless file_paths.empty?
      end
    end

  end

  class NamelessRule < Rule

    def initialize(handler)
      @handler = handler
    end

    def build(input_paths, output_paths, flags)
      @handler.call(input_paths, output_paths, flags)
    end

  end

  class RuleSet

    def initialize(tags)
      @rules = {}
      @tags = Set.new(tags)
    end

    def add_tag(tag)
      @tags.add(tag)
    end

    def add_rule(name, rule)
      @rules[name] = rule
    end

    def get_rule(name, tags)
      return @rules[name] if @tags.superset?(tags)
    end

  end

end

