# frozen_string_literal: true

require 'rainbow'
require 'rubocop'
require 'rubocop-ast'

require_relative 'abc_size/errors'
require_relative 'abc_size/ruby_version'
require_relative 'abc_size/version'

module AbcSize
  # returning ABC size from ABC size calculator
  class Calculator
    SATISFACTORY_ABC_SIZE = 17

    attr_reader :results
    attr_accessor :ruby_version

    def initialize
      @results = []
      @ruby_version = nil
    end

    def call(source_code: nil, path: nil, discount: false)
      source = source_code || source_code_from_file(path)

      ruby_info = RubyVersion.new(path).info
      @ruby_version = ruby_info[:detected] || ruby_info[:default]

      nodes = RuboCop::AST::ProcessedSource.new(source, ruby_version).ast
      nodes.each_node { |node| results << calculate_result(node, discount) if node.is_a?(RuboCop::AST::DefNode) }

      print_everything(ruby_info)

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
        node.body,
        discount_repeated_attributes: discount
      )

      [abc_size, abc, node.method_name]
    end

    def color(input, satisfactory)
      color = satisfactory ? :yellow : :red
      Rainbow(input).color(color)
    end

    def print_everything(ruby_info)
      print_ruby_info(ruby_info)
      print_results
      print_interpretation
    end

    def print_ruby_info(ruby_info)
      notice_for_relative_path_with_error(ruby_info)
      notice_for_relative_path_without_error(ruby_info)
      notice_for_absolute_path(ruby_info)
    end

    def notice_for_relative_path_with_error(ruby_info)
      return unless ruby_info[:relative_path_given] && ruby_info[:error_message]

      puts "Relative path given. #{color(ruby_info[:error_message], false)}\n"\
           "Used parser version: #{color(ruby_version, true)}. "\
           "Supported versions: #{ruby_info[:supported]}\n"\
           "\n"
    end

    def notice_for_relative_path_without_error(ruby_info)
      return unless ruby_info[:relative_path_given] && ruby_info[:error_message].nil?

      puts "Relative path given. #{color('Detection enabled.', true)}\n"\
           "Used parser version: #{color(ruby_version, true)}. "\
           "Supported versions: #{ruby_info[:supported]}\n"\
           "\n"
    end

    def notice_for_absolute_path(ruby_info)
      return if ruby_info[:relative_path_given]

      puts "Absolute path given. #{color('Detection disabled!', false)}\n"\
           "Used parser version: #{color(ruby_version, true)}. "\
           "Supported versions: #{ruby_info[:supported]}\n"\
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
