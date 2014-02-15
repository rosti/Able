require 'set'

module Able

  ##
  # A module that handles logging
  #
  module Logger
    @@loggers = Set.new

    def self.add_logger(logger)
      @@loggers << logger
    end

    def self.call_log_method(meth, *args, &block)
      loggers = @@loggers.select { |logger| logger.methods.include? meth }
      loggers.each { |logger| logger.send meth, *args, &block }
    end

    ##
    # Log arguments
    #
    def self.info *args
      call_log_method :info, *args
    end

    def self.warn *args
      call_log_method :warn, *args
    end

    def self.error *args
      call_log_method :error, *args
    end

  end

end
