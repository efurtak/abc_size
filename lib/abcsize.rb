# frozen_string_literal: true

require_relative 'abcsize/version'

require 'rubocop'

module Abcsize
  class Error < StandardError; end

  # class responsible for returning ABC size from ABC size calculator
  class Abc
    def self.size(path)
      source = File.open(path, 'r').read
      ruby_version = RuboCop::TargetRuby.supported_versions.last

      node = RuboCop::AST::ProcessedSource.new(source, ruby_version).ast
      score = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(node)

      puts  "ABC size: #{Rainbow(score[0]).red}, while: <= 17 satisfactory, 18..30 unsatisfactory, > 30 dangerous\n"\
            "Assignments, branches (method calls), and conditions: #{Rainbow(score[1]).red}"
    end
  end
end
