# frozen_string_literal: true

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

        return_supported_version_if_version_supported(parameters_version)
      end
    end
  end
end
