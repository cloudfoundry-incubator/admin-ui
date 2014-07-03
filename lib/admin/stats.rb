require 'cron_parser'
require 'json'
require_relative 'db/stats_dbstore'
require_relative 'utils'

module AdminUI
  class Stats
    attr_reader :time_last_run

    def initialize(config, logger, cc, varz)
      @config          = config
      @logger          = logger
      @cc              = cc
      @varz            = varz
      @persistence     = AdminUI::StatsDBStore.new(config, logger)

      @data_collection_schedulers = []
      @config.stats_refresh_schedules.each do | spec |
        begin
          cron_parser = CronParser.new(spec)
          @data_collection_schedulers.push(cron_parser)
        rescue => error
          @logger.debug("AdminUI::Stats.initialize: Error detected in the #{spec} of stats_refresh_schedule property as specified in config/default.yml")
          @logger.debug(error.backtrace.join("\n"))
          raise error
        end
        @logger.debug("AdminUI::Stats.initialize: Stats data collection follows schedules #{@config.stats_refresh_schedules}")
      end

      thread = Thread.new do
        loop do
          wait_time = schedule_stats
          if  wait_time <= 0
            @logger.debug('AdminUI::Stats.initialize: Stats collection is disabled.')
            fail
          end
        end
      end

      thread.priority = -2
    end

    def stats
      result = {}

      result['label'] = @config.cloud_controller_uri
      result['items']  = []

      begin
        items = @persistence.retrieve
        items.each do| item |
          item[:timestamp] = item[:timestamp].to_i
        end
        @logger.debug("AdminUI::Stats.stats: Retrieved #{items.length} records.")
        result['items'] = items
      rescue => error
        @logger.debug("AdminUI::Stats.stats: Error retrieving stats data: #{ error }")
        @logger.debug(error.backtrace.join("\n"))
      end

      result
    end

    def current_stats(wait = true)
      {
        :apps              => @cc.applications_count(wait),
        :deas              => @varz.deas_count(wait),
        :organizations     => @cc.organizations_count(wait),
        :running_instances => @cc.applications_running_instances(wait),
        :spaces            => @cc.spaces_count(wait),
        :timestamp         => Utils.time_in_milliseconds,
        :total_instances   => @cc.applications_total_instances(wait),
        :users             => @cc.users_count(wait)
      }
    end

    def create_stats(stats)
      @logger.debug('AdminUI::Stats.create_stats')
      save_stats(stats) ? stats : nil
    end

    def calculate_time_until_generate_stats
      return -1 if @config.stats_refresh_schedules.length == 0
      target_time = Time.now
      init_time = target_time
      current_time_sec = target_time.to_i
      @data_collection_schedulers.each do | scheduler |
        begin
          refresh_time = scheduler.next(init_time)
          if target_time == init_time || target_time > refresh_time
            target_time = refresh_time
          end
        rescue => error
          @logger.debug("AdminUI::Stats.calculate_time_until_generate_stats: Error detected in the #{spec} of stats_refresh_schedule property as specified in config/default.yml")
          @logger.debug(error.backtrace.join("\n"))
          raise error
        end
      end
      wait_time = target_time.to_i - current_time_sec
      @logger.debug("AdminUI::Stats.calculate_time_until_generate_stats:  Next data collection time will be at #{target_time} or #{wait_time} seconds later.")
      wait_time
    end

    private

    def schedule_stats
      wait_time = calculate_time_until_generate_stats
      return -1 if wait_time <= 0
      sleep(wait_time)
      generate_stats
      wait_time
    rescue => error
      @logger.debug("AdminUI::Stats.schedule_stats: Error generating stats: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
    end

    def save_stats(stats)
      result = false

      unless stats.nil?
        begin
          result = @persistence.append(stats)
        rescue => error
          @logger.debug("AdminUI::Stats.save_stats: Error writing stats: #stats, error: #{ error }")
          @logger.debug(error.backtrace.join("\n"))
        end
      end

      result
    end

    def generate_stats
      stats = current_stats(false)

      attempt = 0

      while !save_stats(stats) && (attempt < @config.stats_retries)
        attempt += 1
        @logger.debug("AdminUI::Stats.generate_stats: Waiting #{ @config.stats_retry_interval } seconds before trying to save stats again...")
        sleep(@config.stats_retry_interval)
        stats = current_stats(false)
      end

      @logger.debug('AdminUI::Stats.generate_stats: Reached max number of stat retries, giving up for now...') if attempt == @config.stats_retries
    end
  end
end
