# frozen_string_literal: true

require_relative 'common'

module AbcSize
  module RubyVersion
    # Ruby version picker
    class Picker
      include Common

      attr_reader :parameters, :parameter_index

      def initialize(parameters)
        @parameters = parameters
        @parameter_index = @parameters.index('-r') || @parameters.index('--ruby')
      end

      def call
        return if parameter_index.nil?

        value_index = parameter_index + 1

        parameters_version = parameters[value_index].to_f

        picked_version = return_if_supported_version(parameters_version)
        raise UnsupportedVersionError, 'Unsupported Ruby version given.' if picked_version.nil?

        picked_version
      rescue UnsupportedVersionError => e
        puts "#{e.message}\n"\
             "Supported versions: #{RubyVersion::SUPPORTED_VERSIONS}"
        exit
      end
    end
  end
end
