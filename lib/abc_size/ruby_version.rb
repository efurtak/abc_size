# frozen_string_literal: true

require 'rubocop'

module AbcSize
  # Ruby version detection
  class RubyVersion
    SUPPORTED_VERSIONS = RuboCop::TargetRuby.supported_versions.freeze
    DEFAULT_VERSION = SUPPORTED_VERSIONS.first.freeze

    RUBY_VERSION_FILENAME = '.ruby-version'

    def self.info(path)
      relative_path_given = !path.start_with?('/')

      if relative_path_given
        begin
          data = File.read(RUBY_VERSION_FILENAME, mode: 'r')
          raise EmptyFileError if data.empty?

          match_data = data.match(/\A\d+\.\d+/)
          raise UnknownFormatError if match_data.nil?

          file_version = match_data[0].to_f

          detected_version = SUPPORTED_VERSIONS.include?(file_version) ? file_version : nil
        rescue Errno::ENOENT, EmptyFileError, UnknownFormatError => e
          error_message = assign_error_message(e)
        end
      end

      {
        supported: SUPPORTED_VERSIONS,
        default: DEFAULT_VERSION,
        detected: detected_version,
        relative_path_given: relative_path_given,
        error_message: error_message
      }
    end

    def self.assign_error_message(error)
      case error
      when Errno::ENOENT
        'Not detected .ruby-version file!'
      when EmptyFileError
        'Detected .ruby-version file, but file is empty!'
      when UnknownFormatError
        'Detected .ruby-version file, but file contain unknown format!'
      end
    end
  end
end
