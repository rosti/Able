require 'open3'

module Able
  ##
  # Some common functions used here and there in Able
  #
  module Common
    def sh(*args)
      cmdline = args.map(&:to_s).join ' '
      output, status = Open3.capture2e cmdline

      if status.exitstatus != 0
        Logger.error cmdline
        Logger.error output
        fail "Command failed with status #{status.exitstatus}"
      else
        Logger.verb cmdline
        Logger.verb output
      end
    end
  end
end
