module Able

  class Task

    class Params

      attr_reader :settings
      attr_accessor :input_paths, :output_paths

      def initialize(args)
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

      def prepend_input_path!(path_prefix)
        prepend_path!(:@input_paths, path_prefix)
      end

      def prepend_output_path!(path_prefix)
        prepend_path!(:@output_paths, path_prefix)
      end

      def canonic_input_paths(path_prefix)
        canonize_paths(input_paths, path_prefix)
      end

      def canonic_output_paths(path_prefix)
        canonize_paths(output_paths, path_prefix)
      end

      private

      def prepend_path!(target, path_prefix)
        instance_variable_get(target).map! { |file| path_prefix + file }
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
end