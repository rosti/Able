require 'yaml'

module Able

  class Configuration < Hash

    def initialize(parent = nil)
      merge!(parent.clone) if parent
    end

    def add_option!(key, value)
      self[key] = Array(self[key]) | Array(value)
    end

    def add_pairs!(key, pairs)
      self[key] = Hash(self[key]).merge(pairs)
    end

    def merge_from_file!(filename)
      merge!(YAML.load(File.read(filename)))
    end
  end
end
