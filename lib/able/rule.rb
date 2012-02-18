module Able

  ##
  # The Rule class that handles construction, matching, execution
  # and various other tasks that a rule should be able to handle.
  #
  class Rule
    include AbleCommon

    attr_reader :name, :out_part, :in_part

    ##
    # Constructor for Rule objects
    #
    # [name_or_hash] A String or Symbol name of the rule, or a hash
    #                in the form input_file_pattern => output_file_pattern
    #
    def initialize name_or_hash
      @name = name_or_hash.instance_of?(Hash) ? nil : name_or_hash.to_s
      @out_part = name_or_hash.instance_of?(Hash) ? name_or_hash.to_a[0][1] : nil
      @in_part = name_or_hash.instance_of?(Hash) ? name_or_hash.to_a[0][0] : nil
    end

    ##
    # Check if the rule matches by a given criterion
    #
    # This call takes one argument that is a hash of a symbol pointing to 
    # a match key (the hash can have only one pair for now).
    # Supported symbols are:
    #   [:name] Points to a string that should match the name of the rule.
    #   [:input] Points to a string that should match the input file pattern.
    #   [:output] Points to a string that should match the output file pattern.
    #
    # This function returns true if the criterion matches and false otherwise
    #
    def matches_by? args
      return false if args[:name] and args[:name] != @name
      return false if args[:input] and not args[:input].to_s.end_with? @in_part
      return false if args[:output] and not args[:output].to_s.end_with? @out_part

      return true
    end

    ##
    # Convert a source file name to a target file name
    # This function takes a single argument that is the sorce file name as String
    # 
    def get_target source_name
      source_name.chomp(@in_part) + @out_part
    end

    # Default 'Do Nothing' action functions

    ##
    # Handles building of the input into the output
    #
    # Supported parameters are:
    #   [input] A string or an array of strings pointing to input files.
    #   [output] A string pointing to an output target file.
    #
    # Note that both parameters can be nil, indicating no input or no output (or both).
    #
    def build input, output
    end

    ##
    # Handles generation of a proper string for log entry. The resulting string
    # can be used to be displayed to the user and/or logged somewhere.
    #
    # The function takes the same arguments as #build
    #
    def describe input, output
      "Building: #{input.inspect} => #{output.inspect}"
    end

    ##
    # Return an array (or nil) of strings pointing to additional file dependencies.
    # This function can be used, for example, to get list of included header files in
    # C or C++ source files.
    #
    # The function takes the same arguments as #build
    #
    def extra_depends input, output
    end

  end

end

