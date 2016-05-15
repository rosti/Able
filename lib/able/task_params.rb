module Able

  class Task

    class Params

      attr_reader :settings
      attr_accessor :input_paths, :output_paths

      def initialize(dir, args)
        @dir = dir
        @settings = {}

        # First separate settings from the rest of the arguments
        symbols, rest = *args.partition { |arg| arg.is_a?(Symbol) }
        symbols.each { |sym| @settings[sym] = true }

        # Next, separate and merge hashes from the bare input (if there is any)
        hashes, in_file = *rest.partition { |arg| arg.is_a?(Hash) }
        merged_hash = hashes.inject({}) { |product, h| product.merge(h) }

        # Extract settings from the merged hashes
        setting_keys, in_key = *merged_hash.keys.partition { |key| key.is_a?(Symbol) }
        setting_keys.each { |key| @settings[key] = merged_hash[key] }

        fail 'You may only have one set of source files' if in_file.count + in_key.count > 1
        @input_paths = in_file | in_key.flatten
        @output_paths = in_key.map { |key| merged_hash[key] }
      end

      def build_input_paths
        prepend_paths(@input_paths, @dir.out_dir)
      end

      def build_output_paths
        prepend_paths(@output_paths, @dir.in_dir)
      end

      private

      def prepend_paths(sub_paths, path_prefix)
        sub_paths.map { |sub_path| (path_prefix+sub_path).to_s }
      end
    end
  end
end