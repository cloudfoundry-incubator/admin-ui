require 'spec_helper'

CONFIG_FILE = '/tmp/admin_ui.yml'
DATA_FILE   = '/tmp/admin_ui_data.json'
LOG_FILE    = '/tmp/admin_ui.log'
STATS_FILE  = '/tmp/admin_ui_stats.json'

describe Admin do
  before(:all) do
    config = 
    {
      :cc                   => 'postgres://ccadmin:c1oudc0w@localhost:5524/ccdb',
      :cloud_controller_uri => 'http://api.localhost',
      :data_file            => DATA_FILE,
      :log_file             => LOG_FILE,
      :log_files            => [],
      :mbus                 => 'nats://nats:c1oudc0w@localhost:4222',
      :monitored_components => ['ALL'],
      :port                 => 8070,
      :receiver_emails      => [],
      :sender_email         => {:server => 'localhost', :account => 'system@localhost'},
      :stats_file           => STATS_FILE,
      :uaa                  => 'postgres://uaaadmin:c1oudc0w@localhost:5524/uaadb',
      :ui_admin_credentials => {:username => 'admin', :password => 'passw0rd'},
      :ui_credentials       => {:username => 'user', :password => 'passw0rd'}
    }

    File.open(CONFIG_FILE, 'w') { |file| file.write(JSON.pretty_generate(config)) }

    project_path = File.join(File.dirname(__FILE__), '../..')
    spawn_opts = {:chdir => project_path, :out => '/dev/null', :err => '/dev/null'}

    @pid = Process.spawn({}, "ruby bin/admin -c #{CONFIG_FILE}", spawn_opts)

    sleep(5)
  end
  
  after(:all) do
    Process.kill('TERM', @pid)
    Process.wait(@pid)

    cleanup_files_pid = Process.spawn({}, "rm -fr #{CONFIG_FILE} #{DATA_FILE} #{LOG_FILE} #{STATS_FILE}")
    Process.wait(cleanup_files_pid)
  end

  context 'Login required and performed' do

    before(:all) do
      @http   = Net::HTTP.new('localhost', 8070)
      request = Net::HTTP::Post.new('/login?username=admin&password=passw0rd')
      request['Content-Length'] = 0

      response = @http.request(request)

      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPSeeOther)

      @cookie = response['Set-Cookie']

      @cookie.should_not be_nil
    end

    after(:all) do
      @http   = nil
      @cookie = nil
    end

    def get_json(path)
      request = Net::HTTP::Get.new(path)

      request['Cookie'] = @cookie

      response = @http.request(request)

      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPOK)

      body = response.body
      body.should_not be_nil

      JSON.parse(body)
    end

    def verify_empty_items(path)
      json = get_json(path)

      items = json['items']
      items.should_not be_nil
      items.length.should eq(0)
    end

    it '/applications succeeds' do
      verify_empty_items('/applications')
    end

    it '/cloudControllers succeeds' do
      verify_empty_items('/cloudControllers')
    end

    it '/components succeeds' do
      verify_empty_items('/components')
    end

    it '/dropletExecutionAgents succeeds' do
      verify_empty_items('/dropletExecutionAgents')
    end

    it '/gateways succeeds' do
      verify_empty_items('/gateways')
    end

    it '/healthManagers succeeds' do
      verify_empty_items('/healthManagers')
    end

    it '/logs succeeds' do
      verify_empty_items('/logs')
    end

    it '/organizations succeeds' do
      verify_empty_items('/organizations')
    end

    it '/routers succeeds' do
      verify_empty_items('/routers')
    end

    it '/settings succeeds' do
      json = get_json('/settings')

      json['cloudControllerURI'].should_not be_nil
      json['tasksRefreshInterval'].should_not be_nil
      json['admin'].should_not be_nil
    end

    it '/spaces succeeds' do
      verify_empty_items('/spaces')
    end

    it '/tasks succeeds' do
      verify_empty_items('/tasks')
    end

    it '/users succeeds' do
      verify_empty_items('/users')
    end
  end

  context 'Login required, but not performed' do

    before(:all) do
      @http = Net::HTTP.new('localhost', 8070)
    end

    after(:all) do
      @http = nil
    end

    it '/settings fails as expected' do
      request = Net::HTTP::Get.new('/settings')

      response = @http.request(request)

      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPSeeOther)
    end

  end

  context 'Login not required' do

    before(:all) do
      @http = Net::HTTP.new('localhost', 8070)
    end

    after(:all) do
      @http = nil
    end

   def get_response(path)
      request = Net::HTTP::Get.new(path)

      response = @http.request(request)

      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPOK)

      response
    end

    def get_body(path)
      response = get_response(path)

      body = response.body
      body.should_not be_nil

      body
    end

    def get_json(path)
      body = get_body(path)

      JSON.parse(body)
    end

    it '/ succeeds' do
      get_body('/')
    end

    it '/favicon.ico succeeds' do
      get_response('/favicon.ico')
    end

    it '/statistics succeeds' do
      json = get_json('/statistics')

      json['label'].should_not be_nil

      items = json['items']
      items.should_not be_nil
      items.length.should eq(0)
    end

    it '/stats succeeds' do
      get_body('/stats')
    end

  end

end
