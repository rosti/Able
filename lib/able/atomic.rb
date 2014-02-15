require 'thread'

module Able
  class Atomic
    def initialize(data = nil)
      @data = data
      @mutex = Mutex.new
    end

    def get()
      @mutex.synchronize { @data }
    end

    def set(new_data)
      @mutex.synchronize { @data = new_data }
    end
  end
end
