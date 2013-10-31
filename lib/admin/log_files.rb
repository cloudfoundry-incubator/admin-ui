require_relative 'utils'

module AdminUI
  class LogFiles
    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def logs_info
      result = []

      log_files.each do |log_file|
        result.push(:path => log_file,
                    :size => File.size(log_file),
                    :time => Utils.time_in_milliseconds(File.mtime(log_file)))
      end

      result
    end

    def log_file(path)
      return nil unless log_files.include?(path)

      File.new(path)
    end

    def log_content(path, start)
      return nil unless log_files.include?(path)

      size = File.size(path)

      start = start.nil? ? -1 : start.to_i
      start = (size - @config.log_file_page_size) if start < 0
      start = [start, 0].max

      read_size = [size - start, @config.log_file_page_size].min

      contents = IO.read(path, read_size, start)

      result = {
                 :data      => contents.nil? ? '' : contents,
                 :file_size => size,
                 :page_size => @config.log_file_page_size,
                 :path      => path,
                 :read_size => read_size,
                 :start     => start
               }

      if read_size < size
        if start > 0
          result.merge!(:first => 0)
          back = [start - @config.log_file_page_size, 0].max
          result.merge!(:back => back)
        end

        if start + read_size < size
          forward = [start + @config.log_file_page_size,
                     size - @config.log_file_page_size].min
          result.merge!(:forward => forward)
          result.merge!(:last => -1)
        end
      end

      result
    end

    private

    def log_files
      result = []

      @config.log_files.each do |log_file|
        log_file_path = log_file.to_s

        if File.directory?(log_file_path)
          Dir.entries(log_file_path).each do |fileName|
            file_path = File.join(log_file_path, fileName)
            reslt.push(file_path) if File.file?(file_path)
          end
        else
          Dir.glob(log_file_path).each { |fileName| result.push(fileName) }
        end
      end

      result
    end
  end
end
