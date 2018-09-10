require 'date'

module AdminUI
  class ScheduledThreadPool
    def initialize(logger, number_threads, priority)
      @logger = logger

      @running   = true
      @queue     = []
      @mutex     = Mutex.new
      @condition = ConditionVariable.new
      @threads   = []

      number_threads.times do
        thread = Thread.new do
          while @running
            entry = nil

            @mutex.synchronize do
              first = @queue.first
              entry = @queue.shift if first && first[:time] <= Time.now
            end

            if entry
              begin
                entry[:block].call
              rescue => error
                @logger.error("Error during #{entry[:key]}: #{error.inspect}")
                @logger.error(error.backtrace.join("\n"))
              end
            elsif @running
              # sleep using the @mutex and @condition so shutdown can interrupt
              @mutex.synchronize do
                @condition.wait(@mutex, 1) if @running
              end
            end
          end
        end

        thread.priority = priority

        @threads.push(thread)
      end
    end

    def schedule(key, time, &block)
      return if !@running || key.nil? || time.nil? || block.nil?

      @mutex.synchronize do
        index = @queue.index { |entry| key == entry[:key] }
        if index
          return if @queue.at(index)[:time] <= time

          @queue.delete_at(index)
        end

        if @queue.empty?
          @queue.push(key: key, time: time, block: block)
        else
          index = insert_index(time)
          if index == @queue.length
            @queue.push(key: key, time: time, block: block)
          elsif @queue.at(index)[:time] == time
            @queue.insert(index + 1, key: key, time: time, block: block)
          else
            @queue.insert(index, key: key, time: time, block: block)
          end
        end
      end
    end

    def shutdown
      return unless @running

      @running = false

      @mutex.synchronize do
        @condition.broadcast
      end
    end

    def join
      @threads.each(&:join)
    end

    private

    def insert_index(time)
      s = 0
      e = @queue.length - 1
      while s <= e
        m = (s + e) / 2
        if time < @queue.at(m)[:time]
          e = m - 1
        else
          s = m + 1
        end
      end
      s
    end
  end
end
