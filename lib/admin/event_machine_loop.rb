require 'eventmachine'

# Since both the NATS and WebSocket clients use the EventMachine, we need it running prior to those running.
# If this is not done, when the NATS.stop call is made the EventMachine is potentially stopped.
module AdminUI
  class EventMachineLoop
    def initialize(config, logger, testing)
      @config = config
      @logger = logger

      @running = true

      @thread = Thread.new do
        EventMachine.run do
          timer = EventMachine.add_periodic_timer(testing ? 0.1 : 1) do
            unless @running
              EventMachine.cancel_timer(timer)
              EventMachine.stop_event_loop
            end
          end
        end
      end

      @thread.priority = -1

      # Ensure the EventMachine is running before we return
      until EventMachine.reactor_running?
      end

      EventMachine.error_handler do |error|
        @logger.error("Error during EventMachine: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
      end
    end

    def shutdown
      return unless @running

      @running = false
    end

    def join
      @thread.join
    end
  end
end
