module Able

  ##
  # Simple console logger for Able
  #
  module ConsoleLogger

    def self.log *args
      puts args.map(&:to_s).join(' ')
    end

  end

end
