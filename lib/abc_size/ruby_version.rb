# frozen_string_literal: true

module AbcSize
  module RubyVersion
    SUPPORTED_VERSIONS = RuboCop::TargetRuby.supported_versions.freeze

    # common methods
    module Common
      def return_supported_version_if_version_supported(version)
        supported_version = RubyVersion::SUPPORTED_VERSIONS.include?(version) ? version : nil
        raise UnsupportedVersionError, 'Unsupported Ruby version given.' if supported_version.nil?

        supported_version
      rescue UnsupportedVersionError => e
        puts "#{e.message}\n"\
             "Supported versions: #{RubyVersion::SUPPORTED_VERSIONS}"
        exit
      end
    end
  end
end
