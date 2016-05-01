require 'fileutils'

module Able
  # Base rule class
  class Rule
    include Common

    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def build(_input_paths, _output_paths, _settings) end

    def description(_input_paths, _output_paths, _settings) end

    def make_output_files(_input_paths) end

    def extra_input_paths(_input_paths, _output_paths, _settings) end

    def extra_output_paths(_input_paths, _output_paths, _settings) end

    def clean(_input_paths, output_paths, settings)
      return if settings.include?(:no_clean)

      file_paths = output_paths.select do |path|
        File.exist?(path) && !File.directory?(path)
      end

      File.delete(*file_paths) unless file_paths.empty?
    end
  end

  # Some platform-independent base rules can go here
  module Base
    # simple make path rule
    class Mkpath < Rule
      def build(_in_paths, out_paths, _settings)
        out_paths.each { |path| FileUtils.mkpath(path) }
      end
    end
  end
end
