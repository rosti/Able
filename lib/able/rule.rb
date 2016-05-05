require 'fileutils'

module Able
  # Base rule class
  class Rule
    include Common

    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def build(_params) end

    def description(_params) end

    def make_output_files(_input_paths) end

    def extra_input_paths(_params) end

    def extra_output_paths(_params) end

    def clean(params)
      return if params.settings.include?(:no_clean)

      file_paths = params.output_paths.select do |path|
        File.exist?(path) && !File.directory?(path)
      end

      File.delete(*file_paths) unless file_paths.empty?
    end
  end

  # Some platform-independent base rules can go here
  module Base
    # simple make path rule
    class Mkpath < Rule
      def self.setup(dir)

      end

      def build(params)
        params.output_paths.each { |path| FileUtils.mkpath(path) }
      end
    end
  end
end
