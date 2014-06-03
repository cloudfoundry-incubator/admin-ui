require 'cron_parser'
require 'json'
require_relative 'utils'

module AdminUI
  class Stats
    attr_reader :time_last_run

    def initialize(config, logger, cc, varz)
      @config          = config
      @logger          = logger
      @cc              = cc
      @varz            = varz
      @time_last_run   = Time.now

      @stats_semaphore = Mutex.new

      thread = Thread.new do
        loop do
          time_last_run = schedule_stats
          if  time_last_run < 0
            @logger.debug('stats collection is disabled.')
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

      @stats_semaphore.synchronize do
        begin
          result['items'] = JSON.parse(IO.read(@config.stats_file)) if File.exist?(@config.stats_file)
        rescue => error
          @logger.debug("Error reading stats file: #{ error }")
        end
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
      save_stats(stats) ? stats : nil
    end

    def calculate_time_until_generate_stats
      current_time_sec = Time.now.to_i
      target_time = @time_last_run
      return -1 if @config.stats_refresh_schedules.length == 0
      @logger.debug("stats collection is running according schedule =[#{@config.stats_refresh_schedules}]")
      @config.stats_refresh_schedules.each do | spec |
        begin
          cron_parser = CronParser.new(spec)
          refresh_time = cron_parser.next(@time_last_run).to_i
          if target_time == @time_last_run || target_time > refresh_time
            target_time = refresh_time
          end
        rescue => error
          @logger.debug("Error detected in the '" + spec + "' of stats_refresh_schedule property as specified in config/default.yml")
          @logger.debug(error.backtrace.join("\n"))
          raise error
        end
      end
      target_time - current_time_sec
    end

    private

    def schedule_stats
      time_until_generate_stats = calculate_time_until_generate_stats
      return -1 if time_until_generate_stats < 0
      @logger.debug("Waiting #{ time_until_generate_stats } seconds before trying to save stats...")
      sleep(time_until_generate_stats)
      generate_stats
      @time_last_run = Time.now
    rescue => error
      @logger.debug("Error generating stats: #{ error.inspect }")
    end

    def save_stats(stats)
      result = false

      unless stats.nil?
        @stats_semaphore.synchronize do
          begin
            stats_array = []

            stats_array = JSON.parse(IO.read(@config.stats_file)) if File.exist?(@config.stats_file)

            @logger.debug("Writing stats: #{ stats }")

            stats_array.push(stats)

            File.open(@config.stats_file, 'w') do |file|
              file << JSON.pretty_generate(stats_array)
            end

            result = true
          rescue => error
            @logger.debug("Error writing stats: #stats, error: #{ error }")
          end
        end
      end

      result
    end

    def generate_stats
      stats = current_stats(false)

      attempt = 0

      while !save_stats(stats) && (attempt < @config.stats_retries)
        attempt += 1
        @logger.debug("Waiting #{ @config.stats_retry_interval } seconds before trying to save stats again...")
        sleep(@config.stats_retry_interval)
        stats = current_stats(false)
      end

      @logger.debug('Reached max number of stat retries, giving up for now...') if attempt == @config.stats_retries
    end
  end
end
