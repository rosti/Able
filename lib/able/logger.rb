module Able

  ##
  # A module that handles logging
  #
  module Logger
    @@loggers = []

    def self.use_logger logger
      @@loggers << logger
    end

    def self.call_log_method meth, *args, &block
      loggers = @@loggers.select { |logger| logger.methods.include? meth }
      loggers.each { |logger| logger.send meth, *args, &block }
    end

    ##
    # Log arguments
    #
    def self.log *args
      call_log_method :log, *args
    end

  end

end
