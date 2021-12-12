# frozen_string_literal: true

require 'rainbow'
require 'rubocop'
require 'rubocop-ast'

require_relative 'abc_size/errors'
require_relative 'abc_size/version'
require_relative 'abc_size/version_detector'

module AbcSize
  # returning ABC size from ABC size calculator
  class Calculator
    SATISFACTORY_ABC_SIZE = 17

    attr_reader :results
    attr_accessor :ruby_version

    def initialize
      @results = []
    end

    def call(source_code: nil, path: nil, discount: false)
      source = source_code || source_code_from_file(path)

      version_info = VersionDetector.new(nil).call if source_code # TODO: improve this
      version_info = VersionDetector.new(path).call if path
      @ruby_version = version_info[:detected] || version_info[:default]

      nodes = RuboCop::AST::ProcessedSource.new(source, ruby_version).ast
      nodes.each_node { |node| results << calculate_result(node, discount) if node.is_a?(RuboCop::AST::DefNode) }

      print_everything(version_info)

      # return results for testing purposes
      results
    end

    private

    def source_code_from_file(path)
      data = File.read(path)
      raise Error, 'File is empty!' if data.empty?

      data
    rescue TypeError, Errno::ENOENT, Errno::EISDIR, Error => e
      puts "#{e.message}\n"\
           'Please provide valid path to valid file.'
      exit
    end

    def calculate_result(node, discount)
      abc_size, abc = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(
        node,
        discount_repeated_attributes: discount
      )

      [abc_size, abc, node.method_name]
    end

    def color(input, satisfactory)
      color = satisfactory ? :yellow : :red
      Rainbow(input).color(color)
    end

    def print_everything(version_info)
      print_ruby_info(version_info)
      print_results
      print_interpretation
    end

    def print_ruby_info(version_info)
      notice_for_relative_path_with_error(version_info)
      notice_for_relative_path_without_error(version_info)
      notice_for_absolute_path(version_info)
    end

    def notice_for_relative_path_with_error(version_info)
      return unless version_info[:relative_path_given] && version_info[:error_message]

      puts "Relative path given. #{color(version_info[:error_message], false)}\n"\
           "Used parser version: #{color(ruby_version, true)}. "\
           "Supported versions: #{version_info[:supported]}\n"\
           "\n"
    end

    def notice_for_relative_path_without_error(version_info)
      return unless version_info[:relative_path_given] && version_info[:error_message].nil?

      puts "Relative path given. #{color('Detection enabled.', true)}\n"\
           "Used parser version: #{color(ruby_version, true)}. "\
           "Supported versions: #{version_info[:supported]}\n"\
           "\n"
    end

    def notice_for_absolute_path(version_info)
      return if version_info[:relative_path_given]

      puts "Absolute path given. #{color('Detection disabled!', false)}\n"\
           "Used parser version: #{color(ruby_version, true)}. "\
           "Supported versions: #{version_info[:supported]}\n"\
           "\n"
    end

    def print_results
      results.each do |result|
        abc_size, abc, method_name = result

        satisfactory = abc_size <= SATISFACTORY_ABC_SIZE

        puts "ABC size: #{color(format('%.2f', abc_size), satisfactory)}, "\
             "ABC: #{color(abc, satisfactory)} "\
             "for method: #{color(method_name, satisfactory)}"
      end
    end

    def print_interpretation
      puts "\n"\
           "ABC size: <= 17 satisfactory, 18..30 unsatisfactory, > 30 dangerous\n"\
           'ABC: <assignments, branches (method calls), conditions>'
    end
  end
end
