require 'net/sftp'
require 'uri'
require_relative '../spec_helper'

module SFTPHelper
  class MockSession < ::Net::SFTP::Session
    # rubocop:disable Lint/MissingSuper
    def initialize
      # Intentionally do not call super
    end
    # rubocop:enable Lint/MissingSuper
  end

  class MockEntry
    attr_reader :attributes,
                :name

    def initialize(name)
      @name       = name
      @attributes = ::Net::SFTP::Protocol::V01::Attributes.new
    end
  end

  attr_reader :sftp_attributes_directory,
              :sftp_attributes_file,
              :sftp_attributes_mtime,
              :sftp_attributes_size,
              :sftp_close,
              :sftp_dir_entries,
              :sftp_dir_glob,
              :sftp_download,
              :sftp_fstat,
              :sftp_open,
              :sftp_read,
              :sftp_start

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

    allow(::Net::SFTP).to receive(:start) do |host, user, options, &blk|
      expect(host).to eq(uri.host)
      expect(user).to eq(uri.user)
      expect(options).to include(port: uri.port) unless uri.port.nil?
      expect(options).to include(password: uri.password) unless uri.password.nil?
      expect(options).to include(keys: config.log_file_sftp_keys) if uri.password.nil?

      blk.call(MockSession.new)
      @sftp_start = true
    end

    allow_any_instance_of(MockSession).to receive(:close!) do
      @sftp_close = true
    end

    allow_any_instance_of(MockSession).to receive(:download!) do |_session, _source, target|
      @sftp_download = true
      File.open(target, 'w') do |file|
        file.write(file_content)
      end
    end

    allow_any_instance_of(MockSession).to receive(:fstat!) do
      @sftp_fstat = true

      ::Net::SFTP::Protocol::V01::Attributes.new
    end

    allow_any_instance_of(MockSession).to receive(:open!) do
      @sftp_open = true
      nil
    end

    allow_any_instance_of(MockSession).to receive(:read!) do |_session, _handle, start, read_size|
      @sftp_read = true
      file_content.slice(start, read_size)
    end

    allow_any_instance_of(::Net::SFTP::Protocol::V01::Attributes).to receive(:directory?) do
      @sftp_attributes_directory = true
      !is_file
    end

    allow_any_instance_of(::Net::SFTP::Protocol::V01::Attributes).to receive(:file?) do
      @sftp_attributes_file = true
      is_file
    end

    allow_any_instance_of(::Net::SFTP::Protocol::V01::Attributes).to receive(:mtime) do
      @sftp_attributes_mtime = true
      file_mtime
    end

    allow_any_instance_of(::Net::SFTP::Protocol::V01::Attributes).to receive(:name) do
      @sftp_attributes_name = true
      "#{file_name}#{file_extension}"
    end

    allow_any_instance_of(::Net::SFTP::Protocol::V01::Attributes).to receive(:size) do
      @sftp_attributes_size = true
      file_content.length
    end

    allow_any_instance_of(::Net::SFTP::Operations::Dir).to receive(:entries) do
      # We have to make sure is_file is now true
      is_file = true
      @sftp_dir_entries = true
      [MockEntry.new("#{file_name}#{file_extension}")]
    end

    allow_any_instance_of(::Net::SFTP::Operations::Dir).to receive(:glob) do
      # We have to make sure is_file is now true
      is_file = true
      @sftp_dir_glob = true
      [MockEntry.new("#{file_name}#{file_extension}")]
    end
  end
end
