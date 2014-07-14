require 'fileutils'
require 'sequel'
require 'sequel/extensions/migration'
require 'uri'
require_relative '../spec_helper'

describe AdminUI::DBStoreMigration do
  let(:backup_stats_file)      { '/tmp/admin_ui_stats.json.bak' }
  let(:cloud_controller_uri)   { 'http://api.localhost' }
  let(:config_file)            { '/tmp/admin_ui.yml' }
  let(:data_file)              { '/tmp/admin_ui_data.json' }
  let(:db_file)                { '/tmp/admin_ui_store.db' }
  let(:db_migration_dir)       { 'db/migrations' }
  let(:db_migration_spec_dir)  { 'spec/db' }
  let(:db_uri)                 { "sqlite://#{ db_file }" }
  let(:host)                   { 'localhost' }
  let(:log_file)               { '/tmp/admin_ui.log' }
  let(:plans)                  { ['20140530_new_initial_schema.rb', '201405301000_change_table_schema.rb'] }
  let(:port)                   { 8071 }
  let(:stats_file)             { '/tmp/admin_ui_stats.json' }
  let(:stats_file_spec)        { 'stats.json' }
  let(:tasks_fresh_interval)   { 6000 }
  let(:tasks_refresh_interval) { 6000 }

  let(:config)                 do
    {
      :cloud_controller_uri   => cloud_controller_uri,
      :data_file              => data_file,
      :log_file               => log_file,
      :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
      :port                   => port,
      :db_uri                 => db_uri,
      :tasks_refresh_interval => tasks_fresh_interval,
      :uaa_client             => { :id => 'id', :secret => 'secret' }
    }
  end

  def launch_admin_daemon(config)
    File.delete(db_file) if File.exist?(db_file)
    File.open(config_file, 'w') do |file|
      file.write(JSON.pretty_generate(config))
    end
    project_path = File.join(File.dirname(__FILE__), '../..')
    spawn_opts = { :chdir => project_path,
                   :out   => '/dev/null',
                   :err   => '/dev/null' }

    @pid = Process.spawn({}, "ruby bin/admin -c #{ config_file }", spawn_opts)

    sleep(5)
  end

  def stop_admin_daemon
    Process.kill('TERM', @pid)
    Process.wait(@pid)
    db_migration_1 = plans[1]
    project_path = File.join(File.dirname(__FILE__), '../..')
    spawn_opts = { :chdir => project_path,
                   :out   => '/dev/null',
                   :err   => '/dev/null' }
    @pid = Process.spawn({}, "rm -rf  #{ config_file } #{ data_file } #{ log_file } #{ db_file } #{ backup_stats_file } #{ db_migration_dir }/#{ db_migration_1 } ", spawn_opts)
    Process.wait(@pid)
    FileUtils.rm_f stats_file if File.exist?(stats_file)
  end

  def db_connection
    Sequel.connect db_uri
  end

  def migrate_database
    spawn_opts = { :out   => '/dev/null', :err   => '/dev/null' }

    pid = Process.spawn({}, "sequel -m #{ db_migration_dir } sqlite://#{ db_file }", spawn_opts)
    Process.wait(pid)
  end

  context 'when config property db_uri is using sqlite and the database file does not exist' do
    it 'automatically creates a sqlite database instance.' do
      launch_admin_daemon(config)
      expect(File.exist?(db_file)).to be_true
      stop_admin_daemon
    end
  end

  context 'when config property db_uri is using sqlite and both the database file and its directory do not exist' do
    let(:db_file)    { '/tmp/new_dir/admin_ui_store.db' }

    it 'automatically creates a sqlite database instance.' do
      FileUtils.rm_rf '/tmp/new_dir'  if File.exist?('/tmp/new_dir')
      launch_admin_daemon(config)
      expect(File.exist?(db_file)).to be_true
      stop_admin_daemon
      FileUtils.rm_rf '/tmp/new_dir'
    end
  end

  context 'when stats file exists and database instance does not' do
    it 'migrates stats persistence from file stats to database' do
      merged_config = config.merge(:stats_file => stats_file)
      FileUtils.cp("#{ db_migration_spec_dir }/#{ stats_file_spec }", "#{ stats_file }")
      launch_admin_daemon(merged_config)
      expect(File.file?(db_file)).to be_true
      expect(File.file?(backup_stats_file)).to be_true
      db_conn = db_connection
      db_conn.fetch('select count(*) as rows from stats') do | row |
        expect(row[:rows].to_i).to eq(2)
      end
      stop_admin_daemon
    end
  end

  context 'when there is more than on one database migration plan in db/migrations directory' do
    it 'applies database migration plans according to chronological order' do
      db_migration_1 = plans[1]
      FileUtils.cp "#{ db_migration_spec_dir }/#{ db_migration_1 }", db_migration_dir
      launch_admin_daemon(config)
      db_conn = db_connection
      db_conn.fetch('select tbl_name from sqlite_master where sql like :pattern', :pattern => 'CREATE TABLE%extra_column%') do | row |
        expect(row[:tbl_name]).to eq('stats')
      end
      i = 0
      db_conn.fetch('select filename from schema_migrations') do | row |
        expect(row[:filename]).to eq(plans[i])
        i += 1
      end
      FileUtils.rm_rf "#{ db_migration_dir }/#{ db_migration_1 }"
      stop_admin_daemon
    end
  end

  context 'after adding a new migration plan to the db/migrations directory' do
    it 'allows one to run sequel migration from another process' do
      launch_admin_daemon(config)
      db_migration_1 = plans[1]
      FileUtils.cp "#{ db_migration_spec_dir }/#{ db_migration_1 }", db_migration_dir
      migrate_database
      db_conn = db_connection
      db_conn.fetch('select tbl_name from sqlite_master where sql like :pattern', :pattern => 'CREATE TABLE%extra_column%') do | row |
        expect(row[:tbl_name]).to eq('stats')
      end
      stop_admin_daemon
    end
  end
end
