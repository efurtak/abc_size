# frozen_string_literal: true

module AbcSize
  module RubyVersion
    SUPPORTED_VERSIONS = RuboCop::TargetRuby.supported_versions.freeze

    # common methods
    module Common
      def return_if_supported_version(version)
        RubyVersion::SUPPORTED_VERSIONS.include?(version) ? version : nil
      end
    end
  end
end
