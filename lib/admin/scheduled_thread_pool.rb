require 'date'
require 'thread'

module AdminUI
  class ScheduledThreadPool
    def initialize(logger, number_threads)
      @logger = logger
      @queue  = []
      @mutex  = Mutex.new

      number_threads.times do
        Thread.new do
          loop do
            entry = nil
            now   = Time.now

            @mutex.synchronize do
              first = @queue.first
              entry = @queue.shift if first && first[:time] <= now
            end

            if entry
              begin
                entry[:block].call
              rescue => error
                @logger.debug("Error during #{ entry[:key] }: #{ error.inspect }")
                @logger.debug(error.backtrace.join("\n"))
              end
            end

            sleep 1
          end
        end
      end
    end

    def schedule(key, time, &block)
      return if key.nil? || time.nil? || block.nil?
      entry = { :key => key, :time  => time, :block => block }
      @mutex.synchronize do
        # Intentionally overwrite any existing entry for this key
        @queue.reject! { |existing_entry| key == existing_entry[:key] }
        @queue.push(entry)
        @queue.sort! { |a, b| a[:time] <=> b[:time] }
      end
    end
  end
end
