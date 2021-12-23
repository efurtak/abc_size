# frozen_string_literal: true

module AbcSize
  module RubyVersion
    # Ruby version detector
    class Detector
      include Common

      RUBY_VERSION_FILENAME = '.ruby-version'

      def call
        file_version = return_file_version

        return_supported_version_if_version_supported(file_version)
      rescue Errno::ENOENT, EmptyFileError, UnknownFormatError => e
        rescue_detection_error(e)
      end

      private

      def return_file_version
        data = return_data

        match_data = return_match_data(data)

        match_data[0].to_f
      end

      def return_data
        path = "#{Dir.pwd}/#{RUBY_VERSION_FILENAME}"

        data = File.read(path)
        raise EmptyFileError if data.empty?

        data
      end

      def return_match_data(data)
        match_data = data.match(/\A\d+\.\d+/)
        raise UnknownFormatError if match_data.nil?

        match_data
      end

      def rescue_detection_error(error)
        case error
        when Errno::ENOENT
          puts 'Not detected `.ruby-version` file!'
        when EmptyFileError
          puts 'Detected `.ruby-version` file, but file is empty!'
        when UnknownFormatError
          puts 'Detected `.ruby-version` file, but file contain unknown format!'
        end
        exit
      end
    end
  end
end
