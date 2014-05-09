require 'cron_parser'
require 'logger'
require_relative '../spec_helper'

describe AdminUI::Stats do
  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }
  let(:varz) { AdminUI::VARZ.new(config, logger, nats) }
  let(:client) { AdminUI::CCRestClient.new(config, logger) }
  let(:cc) { AdminUI::CC.new(config, logger, client) }
  let(:stats) { AdminUI::Stats.new(config, logger, cc, varz) }
  let(:config) do
    AdminUI::Config.new(:stats_refresh_schedules      => stats_refresh_schedules,
                        :data_file                    => data_file,
                        :mbus                         => 'nats://nats:c1oudc0w@localhost:14222',
                        :monitored_components         => [],
                        :nats_discovery_timeout       => 1)
  end

  before do
    AdminUI::Config.any_instance.stub(:validate)
  end

  context 'calculate_time_until_generate_stats' do

    shared_examples 'common_calculate_time_until_generate_stats' do
      it 'starts at designated schedule' do
        time_last_run = Time.now
        stats_refresh_schedules.each do |spec|
          cron_parser = CronParser.new(spec)
          current_time = Time.now.to_i
          refresh_time = cron_parser.next(time_last_run).to_i
          sec_to_next_run = refresh_time - current_time
          expect(equal_in_range(stats.calculate_time_until_generate_stats, sec_to_next_run, 2)).to be true
        end
      end
    end
  end

  context 'runs once an hour at the beginning of the hour' do
    let(:stats_refresh_schedules) { ['0 * * * *'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'run once a day at midnight 12:00AM' do
    let(:stats_refresh_schedules) { ['0  0 * * *'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'calculate_time_until_generate_stats' do
    let(:stats_refresh_schedules) { ['0 0 * * 0'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'run once a month at midnight 12:00AM of every first day of the month' do
    let(:stats_refresh_schedules) { ['0 0 1 * *'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'runs once a year at midnight 12:00AM of every January 1st' do
    let(:stats_refresh_schedules) { ['0 0 1 1 *'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'runs once an hour at the beginning of the hour using predefined schedule' do
    let(:stats_refresh_schedules) { ['@hourly'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'run once a day at midnight 12:00AM using predefined schedule' do
    let(:stats_refresh_schedules) { ['@daily'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'run once a day at midnight 12:00AM using predefined schedule' do
    let(:stats_refresh_schedules) { ['@midnight'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'run once a week at midnight 12:00AM of every Sunday using predefined schedule' do
    let(:stats_refresh_schedules) { ['@weekly'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'run once a month at midnight 12:00AM of every first day of the month using predefined schedule' do
    let(:stats_refresh_schedules) { ['@monthly'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'runs once a year at midnight 12:00AM of every January 1st using predefined schedule - @yearly' do
    let(:stats_refresh_schedules) { ['@yearly'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'runs once a year at midnight 12:00AM of every January 1st using predefined schedule - @annually' do
    let(:stats_refresh_schedules) { ['@annually'] }

    it_behaves_like('common_calculate_time_until_generate_stats')
  end

  context 'calculate_time_until_generate_stats for multiple schedules' do

    shared_examples 'common_calculate_time_until_generate_stats_earliest_time_slot' do
      it 'runs starts at the earliest time slot when multiple schedules are specified.' do
        time_last_run = Time.now
        target_time = time_last_run
        stats_refresh_schedules.each do |spec|
          cron_parser = CronParser.new(spec)
          refresh_time = cron_parser.next(time_last_run).to_i
          if target_time == time_last_run || target_time > refresh_time
            target_time = refresh_time
          end
        end
        sec_to_next_run = target_time - time_last_run.to_i
        expect(equal_in_range(stats.calculate_time_until_generate_stats, sec_to_next_run, 2)).to be true
      end
    end
  end

  context 'runs once at 1:00 AM every day and at 12:00PM, 1:00PM, 2:00PM, 3:00PM, 4:00PM, 5:00PM, 8:00PM Monday to Friday - range' do
    let(:stats_refresh_schedules) { ['0 1 * * *', '0 12-17 * * 1-5'] }

    it_behaves_like('common_calculate_time_until_generate_stats_earliest_time_slot')
  end

  context 'runs once at 1:00 AM every day and at 12:00PM, 1:00PM, 2:00PM, 3:00PM, 4:00PM, 5:00PM, 8:00PM Monday to Friday - sequence without steps' do
    let(:stats_refresh_schedules) { ['0 1 * * *', '0 0 12,13,14,15,16,17,20 * * 1-5'] }

    it_behaves_like('common_calculate_time_until_generate_stats_earliest_time_slot')
  end

  context 'runs once at 1:00 AM every day and at 12:00PM, 1:00PM, 2:00PM, 3:00PM, 4:00PM, 5:00PM, 8:00PM Monday to Friday - mix use of range and sequence without step' do
    let(:stats_refresh_schedules) { ['0 1 * * *', '0 0 12,13,15-17,20 * * 1-5'] }

    it_behaves_like('common_calculate_time_until_generate_stats_earliest_time_slot')
  end

  context 'calculate_time_until_generate_stats' do
    let(:config) do
      AdminUI::Config.load(:data_file                    => data_file,
                           :mbus                         => 'nats://nats:c1oudc0w@localhost:14222',
                           :monitored_components         => [],
                           :nats_discovery_timeout       => 1)
    end

    it 'disables stats collection if stats_refresh_time and stats_refresh_schedule are both missing' do
      expect(equal_in_range(stats.calculate_time_until_generate_stats, -1, 2)).to be true
    end
  end

  context 'calculate_time_until_generate_stats' do
    let(:config) do
      AdminUI::Config.new(:stats_refresh_time           => 300,
                          :data_file                    => data_file,
                          :mbus                         => 'nats://nats:c1oudc0w@localhost:14222',
                          :monitored_components         => [],
                          :nats_discovery_timeout       => 1)
    end

    it 'runs according to stats_refresh_time setting when stats_refresh_time is set and stats_refresh_scheduled is not set' do
      time_last_run = Time.now
      target_time = time_last_run
      stats_schedules = ['0 5 * * *']
      stats_schedules.each do |spec|
        cron_parser = CronParser.new(spec)
        refresh_time = cron_parser.next(time_last_run).to_i
        if target_time == time_last_run || target_time > refresh_time
          target_time = refresh_time
        end
      end
      sec_to_next_run = target_time - time_last_run.to_i
      expect(equal_in_range(stats.calculate_time_until_generate_stats, sec_to_next_run, 2)).to be true
    end
  end
end

def equal_in_range(observed, targeted, tolerance)
  (observed - tolerance) <= observed && observed <= (targeted + tolerance)
end
