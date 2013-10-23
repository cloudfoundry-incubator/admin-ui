require 'logger'
require_relative '../spec_helper'

describe IBM::AdminUI::CC do
  let(:log_file) { '/tmp/admin_ui.log' }

  before do
    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG

    config =
    {
      :cloud_controller_uri   => 'http://api.localhost',
      :uaa_admin_credentials  => { :password => 'c1oudc0w', :username => 'admin' }
    }

    IBM::AdminUI::Config.load(config)

    @cc = IBM::AdminUI::CC.new(logger)
  end

  after do
    cleanup_files_pid = Process.spawn({}, "rm -fr #{ log_file }")
    Process.wait(cleanup_files_pid)
  end

  context 'No backend connected' do

    def verify_disconnected_items(result)
      result.should include('connected' => false, 'items' => [])
    end

    it 'returns zero applications as expected' do
      verify_disconnected_items(@cc.applications)
    end

    it 'returns zero application count as expected' do
      applications_count = @cc.applications_count

      applications_count.should eq(0)
    end

    it 'returns zero application running instances as expected' do
      applications_running_instances = @cc.applications_running_instances

      applications_running_instances.should eq(0)
    end

    it 'returns zero application totals instances as expected' do
      applications_total_instances = @cc.applications_total_instances

      applications_total_instances.should eq(0)
    end

    it 'returns zero organizations as expected' do
      verify_disconnected_items(@cc.organizations)
    end

    it 'returns zero organizations count as expected' do
      organizations_count = @cc.organizations_count

      organizations_count.should eq(0)
    end

    it 'returns zero spaces as expected' do
      verify_disconnected_items(@cc.spaces)
    end

    it 'returns zero spaces_auditors as expected' do
      verify_disconnected_items(@cc.spaces_auditors)
    end

    it 'returns zero spaces count as expected' do
      spaces_count = @cc.spaces_count

      spaces_count.should eq(0)
    end

    it 'returns zero spaces_developers as expected' do
      verify_disconnected_items(@cc.spaces_developers)
    end

    it 'returns zero spaces_managers as expected' do
      verify_disconnected_items(@cc.spaces_managers)
    end

    it 'returns zero users as expected' do
      verify_disconnected_items(@cc.users)
    end

    it 'returns zero users count as expected' do
      users_count = @cc.users_count

      users_count.should eq(0)
    end
  end
end
