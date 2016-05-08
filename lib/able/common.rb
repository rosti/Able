require 'open3'

module Able
  ##
  # Some common functions used here and there in Able
  #
  module Common
    def sh(*args)
      cmdline = args.map(&:to_s).join ' '
      output, status = Open3.capture2e cmdline

      Logger.log(status.exitstatus != 0 ? :error: :verbose, cmdline+"\n"+output)
      fail "Command failed with status #{status.exitstatus}" if status.exitstatus != 0
    end
  end
end
