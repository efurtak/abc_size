# frozen_string_literal: true

require 'rainbow'
require 'rubocop'
require 'rubocop-ast'

module AbcSize
  # main class
  class Calculator
    SATISFACTORY_ABC_SIZE = 17

    attr_reader :source_code, :path, :parameters, :discount, :results, :ruby_version

    def initialize(source_code: nil, path: nil, parameters: nil)
      @source_code = source_code
      @path = path
      @parameters = parameters

      @discount = @parameters.map { |parameter| ['-d', '--discount'].include?(parameter) }.any?(true)

      @results = []
    end

    def call
      source = source_code || read_source_code_from_file
      @ruby_version = return_ruby_version

      nodes = RuboCop::AST::ProcessedSource.new(source, ruby_version).ast
      nodes.each_node { |node| results << calculate_result(node) if node.is_a?(RuboCop::AST::DefNode) }

      print_all_messages

      # return results for testing purposes
      results
    end

    private

    def read_source_code_from_file
      data = File.read(path)
      raise EmptyFileError, 'File is empty!' if data.empty?

      data
    rescue TypeError, Errno::ENOENT, Errno::EISDIR, EmptyFileError => e
      puts "#{e.message}\n"\
           'Please provide valid path to valid file.'
      exit
    end

    def return_ruby_version
      ruby_version = RubyVersion::Picker.new(parameters).call || RubyVersion::Detector.new(path).call
      raise UnknownVersionError, 'Ruby version is unknown!' if ruby_version.nil?

      ruby_version
    rescue UnknownVersionError => e
      puts "#{e.message}\n"\
           'Please provide Ruby version with `-r` or `--ruby` option, especially if absolute path given.'
      exit
    end

    def calculate_result(node)
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

    def print_all_messages
      print_versions
      print_results
      print_interpretations
    end

    def print_versions
      puts "Ruby version: #{color(ruby_version, true)}\n"\
           "Supported versions: #{RubyVersion::SUPPORTED_VERSIONS}\n"\
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

    def print_interpretations
      puts "\n"\
           "ABC size: <= 17 satisfactory, 18..30 unsatisfactory, > 30 dangerous\n"\
           'ABC: <assignments, branches (method calls), conditions>'
    end
  end
end
