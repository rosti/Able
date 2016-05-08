require 'colorize'

module Able
  ##
  # Simple console logger for Able
  #
  class ConsoleLogger
    COLOR_MAP = {:verbose => :blue, :info => :green, :warning => :yellow, :error => :red}

    def log(severity, args)
      severity_str = "#{severity}: ".upcase.public_send(COLOR_MAP[severity])
      message_str = args.map(&:to_s).join(' ')
      STDOUT.write(severity_str + message_str + "\n")
    end
  end
end
