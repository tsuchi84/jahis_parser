# frozen_string_literal: true

require 'csv'
require_relative 'jahis_parser/record'

# JAHIS
module JahisParser
  # Loader
  class Loader
    def self.load_from_file(filename)
      rows = CSV.read(filename, encoding: 'CP932:UTF-8')

      record = Record.new(rows.shift)

      rows.each do |row|
        number = row.shift.to_i
        record.set number, row
      end

      record
    end
  end
end
