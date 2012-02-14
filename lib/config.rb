module Able

  ##
  # This class stores a named collection of rules (known simply as "Configuration")
  # These rules can be different on different systems and targets.
  #
  class Configuration
    attr_reader :name

    ##
    # Constructor takes only one string or symbol argument (the configuration name)
    #
    def initialize name
      @name = name.to_s
      @rules = []
    end

    ##
    # Insert a rule ontop of all other rules in the list
    #
    def << rule
      @rules << rule
    end

    ##
    # Get the first rule that matches a given criterion.
    # For criterion documentation see #Able::Rule#matches_by?
    # If nothing is found nil is returned, otherwise an Able::Rule object
    #
    def find_rule_by criterion
      @rules.find { |rule| rule.matches_by? criterion }
    end

    ##
    # Setup a new rule in the current configuration with a given identification
    #
    def rule name_or_hash, &block
      new_rule = Rule.new name_or_hash
      new_rule.instance_eval &block
      @rules << new_rule
    end

  end

end
