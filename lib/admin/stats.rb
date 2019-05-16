require 'cron_parser'
require_relative 'db/stats_dbstore'
require_relative 'utils'

module AdminUI
  class Stats
    attr_reader :time_last_run

    def initialize(config, logger, cc, doppler, varz, testing)
      @config  = config
      @logger  = logger
      @cc      = cc
      @doppler = doppler
      @varz    = varz

      @running = true

      @semaphore = Mutex.new
      @condition = ConditionVariable.new

      @persistence = AdminUI::StatsDBStore.new(config, logger, testing)

      @data_collection_schedulers = []
      @config.stats_refresh_schedules.each do |spec|
        begin
          cron_parser = CronParser.new(spec)
          @data_collection_schedulers.push(cron_parser)
        rescue => error
          @logger.error("AdminUI::Stats.initialize: Error detected in the #{spec} of stats_refresh_schedule property as specified in config/default.yml")
          @logger.error(error.backtrace.join("\n"))
          raise error
        end
        @logger.debug("AdminUI::Stats.initialize: Stats data collection follows schedules #{@config.stats_refresh_schedules}")
      end

      @thread = Thread.new do
        while @running
          wait_time = schedule_stats
          if wait_time <= 0
            @logger.warn('AdminUI::Stats.initialize: Stats collection is disabled.')
            break
          end
        end
      end

      @thread.priority = -2
    end

    def stats
      items = @persistence.retrieve
      items.each do |item|
        item[:timestamp] = item[:timestamp].to_i
      end
      @logger.debug("AdminUI::Stats.stats: Retrieved #{items.length} records.")
      items
    rescue => error
      @logger.error("AdminUI::Stats.stats: Error retrieving stats data: #{error}")
      @logger.error(error.backtrace.join("\n"))
      []
    end

    def current_stats
      {
        apps:              @cc.applications_count,
        cells:             @doppler.reps_count,
        deas:              @doppler.deas_count,
        organizations:     @cc.organizations_count,
        running_instances: @cc.processes_running_instances,
        spaces:            @cc.spaces_count,
        timestamp:         Utils.time_in_milliseconds,
        total_instances:   @cc.processes_total_instances,
        users:             @cc.users_count
      }
    end

    def create_stats(stats)
      @logger.debug('AdminUI::Stats.create_stats')
      save_stats(stats) ? stats : nil
    end

    def calculate_time_until_generate_stats
      return -1 if @config.stats_refresh_schedules.empty?

      target_time = Time.now
      init_time = target_time
      @data_collection_schedulers.each do |scheduler|
        refresh_time = scheduler.next(init_time)
        target_time = refresh_time if target_time == init_time || target_time > refresh_time
      rescue => error
        @logger.error("AdminUI::Stats.calculate_time_until_generate_stats: Error detected in the #{spec} of stats_refresh_schedule property as specified in config/default.yml")
        @logger.error(error.backtrace.join("\n"))
        raise error
      end
      @logger.debug("AdminUI::Stats.calculate_time_until_generate_stats: Next data collection time will be at #{target_time}.")
      target_time.to_i
    end

    def shutdown
      return unless @running

      @running = false

      @semaphore.synchronize do
        @condition.broadcast
      end
    end

    def join
      @thread.join
    end

    private

    def schedule_stats
      target_time = calculate_time_until_generate_stats
      return -1 if target_time.negative?

      while @running && Time.now.to_i < target_time
        wait_time = target_time - Time.now.to_i
        @logger.debug("AdminUI::Stats.schedule_stats(in loop): wait_time #{wait_time} second; now #{Time.now}.")
        @semaphore.synchronize do
          @condition.wait(@semaphore, wait_time) if @running
        end
      end
      generate_stats
      target_time
    rescue => error
      @logger.error("AdminUI::Stats.schedule_stats: Error generating stats: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def save_stats(stats)
      result = false

      unless stats.nil?
        begin
          result = @persistence.append(stats)
        rescue => error
          @logger.error("AdminUI::Stats.save_stats: Error writing stats: #stats, error: #{error}")
          @logger.error(error.backtrace.join("\n"))
        end
      end

      result
    end

    def generate_stats
      stats = current_stats

      attempt = 0

      while @running && !save_stats(stats) && (attempt < @config.stats_retries)
        attempt += 1
        @logger.debug("AdminUI::Stats.generate_stats: Waiting #{@config.stats_retry_interval} seconds before trying to save stats again...")
        @semaphore.synchronize do
          @condition.wait(@semaphore, @config.stats_retry_interval) if @running
        end
        stats = current_stats
      end

      @logger.error('AdminUI::Stats.generate_stats: Reached max number of stat retries, giving up for now...') if attempt == @config.stats_retries
    end
  end
end
