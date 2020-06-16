require 'net/sftp'
require 'tempfile'
require 'uri'
require_relative 'utils'

module AdminUI
  class LogFiles
    def initialize(config, logger)
      @config     = config
      @logger     = logger
      @last_infos = nil
    end

    def content(path, start)
      @last_infos = infos if @last_infos.nil?
      return nil if @last_infos.index { |last_info| last_info[:path] == path }.nil?

      handler = handler_factory(path)
      return nil if handler.nil?

      handler.content(start)
    end

    def file(path)
      @last_infos = infos if @last_infos.nil?
      return nil if @last_infos.index { |last_info| last_info[:path] == path }.nil?

      handler = handler_factory(path)
      return nil if handler.nil?

      handler.file
    end

    def infos
      results = []

      @config.log_files.each do |path|
        handler = handler_factory(path)
        results.concat(handler.infos) unless handler.nil?
      end

      results.uniq! { |result| result[:path] }
      @last_infos = results
    end

    private

    def handler_factory(path)
      return FileHandler.new(@config, @logger, path) if FileHandler.qualifies?(path)
      return SFTPHandler.new(@config, @logger, path) if SFTPHandler.qualifies?(path)

      nil
    end

    class BaseHandler
      def initialize(config, logger, path)
        @config = config
        @logger = logger
        @path   = path
      end

      def calculate_content_start_and_read_size(start, size)
        start = start.nil? ? -1 : start.to_i
        start = (size - @config.log_file_page_size) if start.negative?
        start = [start, 0].max

        read_size = [size - start, @config.log_file_page_size].min

        [start, read_size]
      end

      def create_content_result(file_size, start, read_size, contents)
        result =
          {
            data:      contents.nil? ? '' : contents,
            file_size: file_size,
            page_size: @config.log_file_page_size,
            path:      @path,
            read_size: read_size,
            start:     start
          }

        if read_size < file_size
          if start.positive?
            result[:first] = 0
            result[:back]  = [start - @config.log_file_page_size, 0].max
          end

          if start + read_size < file_size
            result[:forward] = [start + @config.log_file_page_size, file_size - @config.log_file_page_size].min
            result[:last]    = -1
          end
        end

        result
      end
    end

    class FileHandler < BaseHandler
      def content(start)
        begin
          file_size = File.size(@path)

          start, read_size = calculate_content_start_and_read_size(start, file_size)
          contents = IO.read(@path, read_size, start)
          return create_content_result(file_size, start, read_size, contents)
        rescue => error
          @logger.error("Error retrieving contents of log file #{path}: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end

        nil
      end

      def file
        begin
          return File.new(@path)
        rescue => error
          @logger.error("Error downloading file of log file #{path}: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end

        nil
      end

      def infos
        results = []

        begin
          paths.each do |path|
            stat = File.stat(path)
            results.push(path: path,
                         size: stat.size,
                         time: Utils.time_in_milliseconds(stat.mtime))
          end
        rescue => error
          @logger.error("Error retreiving infos of log file #{@path}: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end

        results
      end

      def paths
        results = []

        if File.directory?(@path)
          Dir.entries(@path).each do |file_name|
            entry_path = File.join(@path, file_name)
            results.push(entry_path) if File.file?(entry_path)
          end
        else
          Dir.glob(@path).each { |file_name| results.push(file_name) }
        end

        results
      end

      def self.qualifies?(path)
        scheme = URI.parse(path).scheme
        scheme.nil? || scheme == 'file'
      end
    end

    class SFTPHandler < BaseHandler
      def content(start)
        begin
          uri, options = uri_and_options

          Net::SFTP.start(uri.host, uri.user, options) do |sftp|
            handle = sftp.open!(uri.path)
            begin
              stats = sftp.fstat!(handle)
              if stats.file?
                file_size = stats.size

                start, read_size = calculate_content_start_and_read_size(start, file_size)

                contents = sftp.read!(handle, start, read_size)

                return create_content_result(file_size, start, read_size, contents)
              end
            ensure
              sftp.close!(handle)
            end
          end
        rescue => error
          @logger.error("Error retrieving contents of sftp log file #{path}: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end

        nil
      end

      def file
        begin
          uri, options = uri_and_options

          last_slash = uri.path.rindex('/')
          file_name = uri.path.slice(last_slash + 1, uri.path.length - last_slash)
          ext_name = File.extname(file_name)
          base_name = File.basename(file_name, ext_name)
          temp_file = ext_name.nil? ? Tempfile(base_name) : Tempfile.new([base_name, ext_name])

          Net::SFTP.start(uri.host, uri.user, options) do |sftp|
            sftp.download!(uri.path, temp_file.path)
          end

          return temp_file
        rescue => error
          @logger.error("Error downloading file of sftp log file #{path}: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end

        nil
      end

      def infos
        results = []

        begin
          uri, options = uri_and_options

          uri_path = uri.path
          wildcard = uri_path.index(/[{\[*?]/)

          if wildcard.nil?
            Net::SFTP.start(uri.host, uri.user, options) do |sftp|
              handle = sftp.open!(uri_path)
              begin
                stats = sftp.fstat!(handle)
                if stats.file?
                  results.push(create_info_result(uri, uri_path, stats.size, stats.mtime))
                elsif stats.directory?
                  results.concat(create_info_results(uri, uri_path, sftp.dir.entries(uri_path)))
                end
              ensure
                sftp.close!(handle)
              end
            end
          else
            last_slash   = uri_path.rindex('/', wildcard)
            glob_path    = uri_path.slice(0, last_slash)
            glob_pattern = uri_path.slice(last_slash + 1, uri_path.length - last_slash)

            Net::SFTP.start(uri.host, uri.user, options) do |sftp|
              results.concat(create_info_results(uri, glob_path, sftp.dir.glob(glob_path, glob_pattern)))
            end
          end
        rescue => error
          @logger.error("Error retreiving infos of sftp log file #{@path}: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end

        results
      end

      def create_info_result(uri, path, size, mtime)
        uri_string = "sftp://#{uri.user}"
        uri_string += ":#{uri.password}" unless uri.password.nil?
        uri_string += "@#{uri.host}"
        uri_string += ":#{uri.port}" unless uri.port.nil?
        uri_string += path

        {
          path: uri_string,
          size: size,
          time: Utils.time_in_milliseconds(mtime)
        }
      end

      def create_info_results(uri, base_path, entries)
        results = []

        entries.each do |entry|
          attributes = entry.attributes
          results.push(create_info_result(uri, "#{base_path}/#{entry.name}", attributes.size, attributes.mtime)) if attributes.file?
        end

        results
      end

      def uri_and_options
        uri = URI.parse(@path)
        options = {}
        options[:port] = uri.port unless uri.port.nil?
        if uri.password.nil?
          options[:keys] = @config.log_file_sftp_keys
        else
          options[:password] = uri.password
        end

        [uri, options]
      end

      def self.qualifies?(path)
        URI.parse(path).scheme == 'sftp'
      end
    end
  end
end
