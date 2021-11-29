# frozen_string_literal: true

require_relative 'abcsize/version'

require 'rubocop'
require 'rubocop-ast'
require 'rainbow'

module Abcsize
  class Error < StandardError; end

  # class responsible for returning ABC size from ABC size calculator
  class Abc
    SATISFACTORY_ABC_SIZE = 17

    def size(path)
      source = get_source_from_file(path)
      ruby_version = RuboCop::TargetRuby.supported_versions.last

      nodes = RuboCop::AST::ProcessedSource.new(source, ruby_version).ast

      nodes.each_node { |n| return_result(n) if n.is_a?(RuboCop::AST::DefNode) }

      print_interpretation
    end

    private

    def get_source_from_file(path)
      content = File.open(path, 'r').read
      raise Error, 'File is empty!' if content.empty?

      content
    rescue TypeError, Errno::ENOENT, Errno::EISDIR, Error => e
      puts  "#{e.message}\n"\
            'Please provide valid path to valid file.'
      exit
    end

    def return_result(node)
      abc_size, abc = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(node)

      satisfactory = abc_size <= SATISFACTORY_ABC_SIZE

      puts "ABC size: #{color(format('%.2f', abc_size), satisfactory)}, "\
           "ABC: #{color(abc, satisfactory)} "\
           "for method: #{color(node.method_name, satisfactory)}"

      [abc_size, abc]
    end

    def color(input, satisfactory)
      color = satisfactory ? :yellow : :red
      Rainbow(input).color(color)
    end

    def print_interpretation
      puts  "\n"\
            "ABC size: <= 17 satisfactory, 18..30 unsatisfactory, > 30 dangerous\n"\
            'ABC: <assignments, branches (method calls), conditions>'
    end
  end
end
