require 'set'
require 'thread'

module Able
  ##
  # A module that handles logging
  #
  module Logger
    @@loggers = Set.new
    @@mutex = Mutex.new

    def self.add_logger(logger)
      @@loggers << logger
    end

    def self.call_log_method(meth, *args, &block)
      @@mutex.synchronize do
        loggers = @@loggers.select { |logger| logger.methods.include? meth }
        loggers.each { |logger| logger.send meth, *args, &block }
      end
    end

    ##
    # Log arguments
    #
    def self.verb(*args)
      call_log_method :verb, *args if $verbose or ENV['V'].to_i == 1
    end

    def self.info(*args)
      call_log_method :info, *args
    end

    def self.warn(*args)
      call_log_method :warn, *args
    end

    def self.error(*args)
      call_log_method :error, *args
    end
  end
end
