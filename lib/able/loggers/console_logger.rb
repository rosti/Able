module Able

  ##
  # Simple console logger for Able
  #
  module ConsoleLogger

    def self.info *args
      puts args.map(&:to_s).join(' ')
    end

    def self.warn *args
      puts args.map(&:to_s).join(' ')
    end

    def self.error *args
      puts args.map(&:to_s).join(' ')
    end

  end

end
