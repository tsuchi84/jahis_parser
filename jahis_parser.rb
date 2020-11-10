# frozen_string_literal: true

require 'json'
require_relative 'jahis_parser/record'

# JAHIS
module JahisParser
  # Loader
  class Loader
    require 'csv'

    def initialize(filename)
      @filename = filename
    end

    def exec
      rows = CSV.read(@filename, encoding: 'CP932:UTF-8')

      record = Record.new(rows.shift)

      rows.each do |row|
        number = row.shift.to_i
        record.set number, row
      end

      pp record
    end
  end
end
