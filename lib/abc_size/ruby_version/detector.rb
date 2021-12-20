# frozen_string_literal: true

module AbcSize
  module RubyVersion
    # Ruby version detector
    class Detector
      include Common

      RUBY_VERSION_FILENAME = '.ruby-version'

      attr_reader :path

      def initialize(path)
        @path = path
      end

      def call
        return unless relative_path_given?

        file_version = return_file_version

        detected_version = return_if_supported_version(file_version)
        raise UnsupportedVersionError, 'Unsupported Ruby version given.' if detected_version.nil?

        detected_version
      rescue Errno::ENOENT, EmptyFileError, UnknownFormatError => e
        rescue_detection_error(e)
      rescue UnsupportedVersionError => e
        rescue_unsupported_version_error(e)
      end

      private

      def relative_path_given?
        !path.start_with?('/') if path
      end

      def return_file_version
        data = return_data

        match_data = return_match_data(data)

        match_data[0].to_f
      end

      def return_data
        data = File.read(RUBY_VERSION_FILENAME)
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

      def rescue_unsupported_version_error(error)
        puts "#{error.message}\n"\
             "Supported versions: #{RubyVersion::SUPPORTED_VERSIONS}"
        exit
      end
    end
  end
end
