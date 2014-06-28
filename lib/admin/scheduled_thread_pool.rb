require 'date'
require 'thread'

module AdminUI
  class ScheduledThreadPool
    def initialize(logger, number_threads, priority)
      @logger = logger
      @queue  = []
      @mutex  = Mutex.new
      @sleep_time_factor = 0.05 + 0.1 * priority * priority

      number_threads.times do
        thread = Thread.new do
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

            sleep @sleep_time_factor
          end
        end

        thread.priority = priority
      end
    end

    def schedule(key, time, &block)
      return if key.nil? || time.nil? || block.nil?
      @mutex.synchronize do
        index = @queue.index { |entry| key == entry[:key] }
        if index
          return if @queue.at(index)[:time] <= time
          @queue.delete_at(index)
        end
        @queue.push(:key => key, :time  => time, :block => block)
        @queue.sort! { |a, b| a[:time] <=> b[:time] }
      end
    end
  end
end
