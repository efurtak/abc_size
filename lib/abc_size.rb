# frozen_string_literal: true

require_relative 'abc_size/version'

require 'rubocop'
require 'rubocop-ast'
require 'rainbow'

module AbcSize
  class Error < StandardError; end

  # class responsible for returning ABC size from ABC size calculator
  class Calculator
    SATISFACTORY_ABC_SIZE = 17

    attr_reader :results

    def initialize
      @results = []
    end

    def call(source_code: nil, path: nil, discount: false)
      source = source_code || source_code_from_file(path)
      ruby_version = RuboCop::TargetRuby.supported_versions.last

      nodes = RuboCop::AST::ProcessedSource.new(source, ruby_version).ast

      nodes.each_node { |node| results << calculate_result(node, discount) if node.is_a?(RuboCop::AST::DefNode) }

      print_results

      print_interpretation

      # return results for testing purposes
      results
    end

    private

    def source_code_from_file(path)
      data = File.open(path, 'r').read
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

    def print_results
      results.each do |result|
        abc_size, abc, method_name = result

        satisfactory = abc_size <= SATISFACTORY_ABC_SIZE

        puts "ABC size: #{color(format('%.2f', abc_size), satisfactory)}, "\
             "ABC: #{color(abc, satisfactory)} "\
             "for method: #{color(method_name, satisfactory)}"
      end
    end

    def color(input, satisfactory)
      color = satisfactory ? :yellow : :red
      Rainbow(input).color(color)
    end

    def print_interpretation
      puts "\n"\
           "ABC size: <= 17 satisfactory, 18..30 unsatisfactory, > 30 dangerous\n"\
           'ABC: <assignments, branches (method calls), conditions>'
    end
  end
end
