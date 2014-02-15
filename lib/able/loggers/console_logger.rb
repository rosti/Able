require 'colorize'

module Able

  ##
  # Simple console logger for Able
  #
  module ConsoleLogger

    def self.log *args
      STDOUT.write args.map(&:to_s).join(' ') + "\n"
    end

    def self.info *args
      log "INFO:".green, *args
    end

    def self.warn *args
      log "WARNING:".yellow, *args
    end

    def self.error *args
      log "ERROR:".red, *args
    end

  end

end
