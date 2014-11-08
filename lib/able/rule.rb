require 'fileutils'

module Able
  # Base rule class
  class Rule
    include Common

    def build(_input_paths, _output_paths, _flags) end

    def description(_input_paths, _output_paths, _flags) end

    def make_output_files(_input_paths) end

    def extra_input_paths(_input_paths, _output_paths, _flags) end

    def extra_output_paths(_input_paths, _output_paths, _flags) end

    def clean(_input_paths, output_paths, flags)
      return if flags.include?(:no_clean)

      file_paths = output_paths.select do |path|
        File.exist?(path) && !File.directory?(path)
      end

      File.delete(*file_paths) unless file_paths.empty?
    end
  end

  # A rule that can only build things
  class BasicRule < Rule
    def initialize(handler)
      @handler = handler
    end

    def build(input_paths, output_paths, flags)
      @handler.call(input_paths, output_paths, flags)
    end
  end

  # Some platform-independent base rules can go here
  module Base
    # simple make path rule
    class Mkpath < Rule
      def build(_in_paths, out_paths, _flags)
        out_paths.each { |path| FileUtils.mkpath(path) }
      end
    end

    RULES = {
      mkdir: Mkpath.new,
    }
  end
end
