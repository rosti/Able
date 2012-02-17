require 'open3'

module Able

  ##
  # Some common functions used here and there in Able
  #
  module AbleCommon

    def log *args
      puts args.map(&:to_s).join ' '
      $ABLE_LOGGER.log *args if $ABLE_LOGGER
    end

    def sh *args
      cmdline = args.map(&:to_s).join ' '
      output, status = Open3.capture2e cmdline

      if status.exitstatus != 0
        log cmdline
        log output
        raise "Command failed with status #{status.exitstatus}"
      end
    end

  end

end
