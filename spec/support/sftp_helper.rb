require 'net/sftp'
require 'uri'
require_relative '../spec_helper'

module SFTPHelper
  class MockSession < ::Net::SFTP::Session
    def initialize
      # Intentionally do not call super
    end
  end

  class MockEntry
    attr_reader :attributes
    attr_reader :name
    def initialize(name)
      @name       = name
      @attributes = ::Net::SFTP::Protocol::V01::Attributes.new
    end
  end

  attr_reader :sftp_attributes_directory
  attr_reader :sftp_attributes_file
  attr_reader :sftp_attributes_mtime
  attr_reader :sftp_attributes_size
  attr_reader :sftp_close
  attr_reader :sftp_dir_entries
  attr_reader :sftp_dir_glob
  attr_reader :sftp_download
  attr_reader :sftp_fstat
  attr_reader :sftp_open
  attr_reader :sftp_read
  attr_reader :sftp_start

  def sftp_stub(config, is_file, file_name, file_extension, file_content, file_mtime)
    @sftp_attributes_directory = false
    @sftp_attributes_file      = false
    @sftp_attributes_mtime     = false
    @sftp_attributes_name      = false
    @sftp_attributes_size      = false
    @sftp_close                = false
    @sftp_dir_entries          = false
    @sftp_dir_glob             = false
    @sftp_download             = false
    @sftp_fstat                = false
    @sftp_open                 = false
    @sftp_read                 = false
    @sftp_start                = false

    uri = URI.parse(config.log_files[0])

    ::Net::SFTP.stub(:start) do |host, user, options, &blk|
      expect(host).to eq(uri.host)
      expect(user).to eq(uri.user)
      expect(options).to include(:port => uri.port) unless uri.port.nil?
      expect(options).to include(:password => uri.password) unless uri.password.nil?
      expect(options).to include(:keys => config.log_file_sftp_keys) if uri.password.nil?

      blk.call(MockSession.new)
      @sftp_start = true
    end

    MockSession.any_instance.stub(:close!) do
      @sftp_close = true
    end

    MockSession.any_instance.stub(:download!) do |source, target|
      @sftp_download = true
      File.open(target, 'w') do |file|
        file.write(file_content)
      end
    end

    MockSession.any_instance.stub(:fstat!) do
      @sftp_fstat = true

      ::Net::SFTP::Protocol::V01::Attributes.new
    end

    MockSession.any_instance.stub(:open!) do
      @sftp_open = true
      nil
    end

    MockSession.any_instance.stub(:read!) do |_, start, read_size|
      @sftp_read = true
      file_content.slice(start, read_size)
    end

    ::Net::SFTP::Protocol::V01::Attributes.any_instance.stub(:directory?) do
      @sftp_attributes_directory = true
      !is_file
    end

    ::Net::SFTP::Protocol::V01::Attributes.any_instance.stub(:file?) do
      @sftp_attributes_file = true
      is_file
    end

    ::Net::SFTP::Protocol::V01::Attributes.any_instance.stub(:mtime) do
      @sftp_attributes_mtime = true
      file_mtime
    end

    ::Net::SFTP::Protocol::V01::Attributes.any_instance.stub(:name) do
      @sftp_attributes_name = true
      "#{ file_name }#{ file_extension }"
    end

    ::Net::SFTP::Protocol::V01::Attributes.any_instance.stub(:size) do
      @sftp_attributes_size = true
      file_content.length
    end

    ::Net::SFTP::Operations::Dir.any_instance.stub(:entries) do
      # We have to make sure if_file is now true
      is_file = true
      @sftp_dir_entries = true
      [MockEntry.new("#{ file_name }#{ file_extension }")]
    end

    ::Net::SFTP::Operations::Dir.any_instance.stub(:glob) do
      # We have to make sure if_file is now true
      is_file = true
      @sftp_dir_glob = true
      [MockEntry.new("#{ file_name }#{ file_extension }")]
    end
  end
end
