# frozen_string_literal: true

require_relative 'abcsize/version'

require 'rubocop'

module Abcsize
  class Error < StandardError; end

  # class responsible for returning ABC size from ABC size calculator
  class Abc
    def size(path)
      source = get_source_from_file(path)
      ruby_version = RuboCop::TargetRuby.supported_versions.last

      node = RuboCop::AST::ProcessedSource.new(source, ruby_version).ast

      abc_size, abc = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(node)

      puts  "ABC size: #{abc_size}, while: <= 17 satisfactory, 18..30 unsatisfactory, > 30 dangerous\n"\
            "Assignments, branches (method calls), conditions: #{abc}"
    end

    private

    def get_source_from_file(path)
      file = File.open(path, 'r').read

      raise Error, 'File is empty!' if file.empty?

      file
    rescue TypeError, Errno::ENOENT, Errno::EISDIR, Error => e
      puts "#{e.message}\nPlease provide valid path to valid file."
      exit
    end
  end
end
