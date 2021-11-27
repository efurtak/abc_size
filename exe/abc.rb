#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift("#{__dir__}/../lib")

require 'abcsize'

Abcsize::Abc.size(ARGV.first)
