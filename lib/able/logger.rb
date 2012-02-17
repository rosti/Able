module Able

  ##
  # A class that handles logging
  #
  class Logger
    attr_reader :name

    ##
    # Create a new logger with a given name
    #
    def initialize name
      @name = name
    end

    ##
    # Log arguments
    # This function can be overwritten
    #
    def log *args
    end

  end

end
