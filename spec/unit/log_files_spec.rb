require 'logger'
require_relative '../spec_helper'

describe AdminUI::LogFiles do
  include ConfigHelper
  include SFTPHelper

  let(:log_file_content)   { 'This is sample file content. It is not really very long. But, will suffice for testing' }
  let(:log_file_extension) { 'log' }
  let(:log_file_mtime)     { Time.new(1976, 7, 4, 12, 34, 56, 0) }
  let(:log_file_name)      { 'test' }
  let(:log_file_sftp_key)  { '/somedir/somefile' }
  let(:system_log_file)    { '/tmp/admin_ui.log' }

  let(:config) do
    AdminUI::Config.load(log_files:         [log_file_uri],
                         log_file_sftp_key: [log_file_sftp_key])
  end

  let(:logger)    { Logger.new(system_log_file) }
  let(:log_files) { AdminUI::LogFiles.new(config, logger) }

  before do
    config_stub
  end

  after do
    Process.wait(Process.spawn({}, "rm -fr #{system_log_file}"))
  end

  context 'File' do
    let(:log_file_directory) { '/tmp/admin_logs' }
    let(:log_file_qualified_name) { "#{log_file_directory}/#{log_file_name}#{log_file_extension}" }

    before do
      Dir.mkdir(log_file_directory)
      File.open(log_file_qualified_name, 'w') do |file|
        file.write(log_file_content)
      end
      File.utime(log_file_mtime, log_file_mtime, log_file_qualified_name)
    end

    after do
      Process.wait(Process.spawn({}, "rm -fr #{log_file_directory}"))
    end

    shared_examples 'common FILE actions' do
      it 'returns the log file in the infos call' do
        infos = log_files.infos

        expect(infos).to include(path: log_file_qualified_name,
                                 size: log_file_content.length,
                                 time: AdminUI::Utils.time_in_milliseconds(log_file_mtime))
      end

      it 'makes available the file object' do
        infos = log_files.infos
        info = infos[0]
        file = log_files.file(info[:path])
        content = IO.read(file.path)
        expect(content).to eq(log_file_content)
      end

      it 'downloads entire content' do
        infos = log_files.infos
        info = infos[0]
        content = log_files.content(info[:path], nil)
        expect(content).to eq(data:      log_file_content,
                              file_size: log_file_content.length,
                              page_size: config.log_file_page_size,
                              path:      log_file_qualified_name,
                              read_size: log_file_content.length,
                              start:     0)
      end

      it 'downloads partial content' do
        start  = log_file_content.length / 2
        length = log_file_content.length - start

        infos = log_files.infos
        info = infos[0]
        content = log_files.content(info[:path], start)
        expect(content).to eq(back:      0,
                              data:      log_file_content.slice(start, log_file_content.length - start),
                              file_size: log_file_content.length,
                              first:     0,
                              page_size: config.log_file_page_size,
                              path:      log_file_qualified_name,
                              read_size: length,
                              start:     start)
      end
    end

    context 'file' do
      let(:log_file_uri) { log_file_qualified_name }

      it_behaves_like('common FILE actions') {} # intentionally empty
    end

    context 'directory' do
      let(:log_file_uri) { log_file_directory }

      it_behaves_like('common FILE actions') {} # intentionally empty
    end

    context 'glob' do
      let(:log_file_uri) { "#{log_file_directory}/**/*#{log_file_extension}" }

      it_behaves_like('common FILE actions') {} # intentionally empty
    end
  end

  context 'SFTP' do
    let(:log_file_directory) { 'admin_logs' }

    before do
      sftp_stub(config, is_file, log_file_name, log_file_extension, log_file_content, log_file_mtime)
    end

    shared_examples 'common SFTP actions' do
      it 'makes available the file object' do
        infos = log_files.infos
        info = infos[0]
        file = log_files.file(info[:path])
        expect(sftp_start).to be(true)
        expect(sftp_download).to be(true)
        content = IO.read(file.path)
        expect(content).to eq(log_file_content)
      end

      it 'downloads entire content' do
        infos = log_files.infos
        info = infos[0]
        content = log_files.content(info[:path], nil)
        expect(sftp_start).to be(true)
        expect(sftp_open).to be(true)
        expect(sftp_read).to be(true)
        expect(sftp_close).to be(true)
        expect(content).to eq(data:      log_file_content,
                              file_size: log_file_content.length,
                              page_size: config.log_file_page_size,
                              path:      info[:path],
                              read_size: log_file_content.length,
                              start:     0)
      end

      it 'downloads partial content' do
        start  = log_file_content.length / 2
        length = log_file_content.length - start

        infos = log_files.infos
        info = infos[0]
        content = log_files.content(info[:path], start)
        expect(sftp_start).to be(true)
        expect(sftp_open).to be(true)
        expect(sftp_read).to be(true)
        expect(sftp_close).to be(true)
        expect(content).to eq(back:      0,
                              data:      log_file_content.slice(start, log_file_content.length - start),
                              file_size: log_file_content.length,
                              first:     0,
                              page_size: config.log_file_page_size,
                              path:      info[:path],
                              read_size: length,
                              start:     start)
      end
    end

    context 'file' do
      let(:is_file) { true }

      context 'user and password credentials' do
        let(:log_file_uri) { "sftp://user:password@bogus.com/#{log_file_directory}/#{log_file_name}#{log_file_extension}" }

        it 'returns the log file in the infos call' do
          infos = log_files.infos

          expect(sftp_start).to be(true)
          expect(sftp_open).to be(true)
          expect(sftp_fstat).to be(true)
          expect(sftp_attributes_file).to be(true)
          expect(sftp_attributes_directory).to be(false)
          expect(sftp_attributes_size).to be(true)
          expect(sftp_attributes_mtime).to be(true)
          expect(sftp_close).to be(true)

          expect(infos).to include(path: log_file_uri,
                                   size: log_file_content.length,
                                   time: AdminUI::Utils.time_in_milliseconds(log_file_mtime))
        end

        it_behaves_like('common SFTP actions') {} # intentionally empty
      end

      context 'user and implied key' do
        let(:log_file_uri) { "sftp://user@bogus.com/#{log_file_directory}/#{log_file_name}#{log_file_extension}" }

        it 'returns the log file in the infos call' do
          infos = log_files.infos

          expect(sftp_start).to be(true)
          expect(sftp_open).to be(true)
          expect(sftp_fstat).to be(true)
          expect(sftp_attributes_file).to be(true)
          expect(sftp_attributes_directory).to be(false)
          expect(sftp_attributes_size).to be(true)
          expect(sftp_attributes_mtime).to be(true)
          expect(sftp_close).to be(true)

          expect(infos).to include(path: log_file_uri,
                                   size: log_file_content.length,
                                   time: AdminUI::Utils.time_in_milliseconds(log_file_mtime))
        end

        it_behaves_like('common SFTP actions') {} # intentionally empty
      end
    end

    context 'directory' do
      let(:is_file) { false }

      context 'user and password credentials' do
        let(:log_file_uri) { "sftp://user:password@bogus.com/#{log_file_directory}" }

        it 'returns the log file in the infos call' do
          infos = log_files.infos

          expect(sftp_start).to be(true)
          expect(sftp_open).to be(true)
          expect(sftp_fstat).to be(true)
          expect(sftp_attributes_file).to be(true)
          expect(sftp_attributes_directory).to be(true)
          expect(sftp_dir_entries).to be(true)
          expect(sftp_attributes_size).to be(true)
          expect(sftp_attributes_mtime).to be(true)
          expect(sftp_close).to be(true)

          expect(infos).to include(path: "#{log_file_uri}/#{log_file_name}#{log_file_extension}",
                                   size: log_file_content.length,
                                   time: AdminUI::Utils.time_in_milliseconds(log_file_mtime))
        end

        it_behaves_like('common SFTP actions') {} # intentionally empty
      end

      context 'user and implied key' do
        let(:log_file_uri) { "sftp://user@bogus.com/#{log_file_directory}" }

        it 'returns the log file in the infos call' do
          infos = log_files.infos

          expect(sftp_start).to be(true)
          expect(sftp_open).to be(true)
          expect(sftp_fstat).to be(true)
          expect(sftp_attributes_file).to be(true)
          expect(sftp_attributes_directory).to be(true)
          expect(sftp_dir_entries).to be(true)
          expect(sftp_attributes_size).to be(true)
          expect(sftp_attributes_mtime).to be(true)
          expect(sftp_close).to be(true)

          expect(infos).to include(path: "#{log_file_uri}/#{log_file_name}#{log_file_extension}",
                                   size: log_file_content.length,
                                   time: AdminUI::Utils.time_in_milliseconds(log_file_mtime))
        end

        it_behaves_like('common SFTP actions') {} # intentionally empty
      end
    end

    context 'glob' do
      let(:is_file) { false }

      context 'user and password credentials' do
        let(:base_path) { "sftp://user:password@bogus.com/#{log_file_directory}" }
        let(:log_file_uri) { "#{base_path}/**/*#{log_file_extension}" }

        it 'returns the log file in the infos call' do
          infos = log_files.infos

          expect(sftp_start).to be(true)
          expect(sftp_dir_glob).to be(true)
          expect(sftp_attributes_file).to be(true)
          expect(sftp_attributes_size).to be(true)
          expect(sftp_attributes_mtime).to be(true)

          expect(infos).to include(path: "#{base_path}/#{log_file_name}#{log_file_extension}",
                                   size: log_file_content.length,
                                   time: AdminUI::Utils.time_in_milliseconds(log_file_mtime))
        end

        it_behaves_like('common SFTP actions') {} # intentionally empty
      end

      context 'user and implied key' do
        let(:base_path) { "sftp://user@bogus.com/#{log_file_directory}" }
        let(:log_file_uri) { "#{base_path}/**/*#{log_file_extension}" }

        it 'returns the log file in the infos call' do
          infos = log_files.infos

          expect(sftp_start).to be(true)
          expect(sftp_dir_glob).to be(true)
          expect(sftp_attributes_file).to be(true)
          expect(sftp_attributes_size).to be(true)
          expect(sftp_attributes_mtime).to be(true)

          expect(infos).to include(path: "#{base_path}/#{log_file_name}#{log_file_extension}",
                                   size: log_file_content.length,
                                   time: AdminUI::Utils.time_in_milliseconds(log_file_mtime))
        end

        it_behaves_like('common SFTP actions') {} # intentionally empty
      end
    end
  end
end
