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
    # Log arguments to console
    # This function can be overwritten
    #
    def log *args
      puts args.map(&:to_s).join(' ')
    end

  end

end
