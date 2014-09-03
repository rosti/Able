require 'fileutils'

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

  class BasicRule < Rule

    def initialize(handler)
      @handler = handler
    end

    def build(input_paths, output_paths, flags)
      @handler.call(input_paths, output_paths, flags)
    end

  end

  module Base

    class Mkpath < Rule
      def build(in_paths, out_paths, flags)
        out_paths.each { |path| FileUtils.mkpath(path) }
      end
    end

    Rules = {
      mkdir: Mkpath.new,
    }

  end

end

