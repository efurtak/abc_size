# frozen_string_literal: true

require 'rubocop'

module AbcSize
  # version detector
  class VersionDetector
    SUPPORTED_VERSIONS = RuboCop::TargetRuby.supported_versions.freeze
    DEFAULT_VERSION = SUPPORTED_VERSIONS.first.freeze

    RUBY_VERSION_FILENAME = '.ruby-version'

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def call
      if relative_path_given?
        begin
          file_version = return_file_version

          detected_version = SUPPORTED_VERSIONS.include?(file_version) ? file_version : nil
        rescue Errno::ENOENT, EmptyFileError, UnknownFormatError => e
          error_message = assign_error_message(e)
        end
      end

      version_info(SUPPORTED_VERSIONS, DEFAULT_VERSION, detected_version, relative_path_given?, error_message)
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

    def assign_error_message(error)
      case error
      when Errno::ENOENT
        'Not detected .ruby-version file!'
      when EmptyFileError
        'Detected .ruby-version file, but file is empty!'
      when UnknownFormatError
        'Detected .ruby-version file, but file contain unknown format!'
      end
    end

    def version_info(supported_versions, default_version, detected_version, relative_path_given, error_message)
      {
        supported: supported_versions,
        default: default_version,
        detected: detected_version,
        relative_path_given: relative_path_given,
        error_message: error_message
      }
    end
  end
end
