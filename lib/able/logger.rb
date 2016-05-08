module Able
  ##
  # A module that handles logging
  #
  module Logger
    @@loggers = []

    def self.add_logger(logger)
      @@loggers << logger
    end

    def self.log(severity, *args)
      unless severity == :verbose and not($verbose or ENV['V'].to_i == 1)
        @@loggers.each { |logger| logger.log(severity, args) }
      end
    end

    ##
    # Log arguments
    #
    def self.verb(*args)
      log :verbose, *args
    end

    def self.info(*args)
      log :info, *args
    end

    def self.warn(*args)
      log :warning, *args
    end

    def self.error(*args)
      log :error, *args
    end
  end
end
