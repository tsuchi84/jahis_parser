require_relative 'jahis_parser'
require 'json'
require 'yaml'
# require 'active_support'
# require 'active_support/core_ext/hash'

(1..11).each do |n|
  p n
  record = JahisParser::Loader.load_from_file("sample_data/#{n}.csv")

  puts JSON.pretty_generate(record.to_hash)
  # puts YAML.dump(record.to_hash.deep_stringify_keys)
  # pp record.to_hash
end
