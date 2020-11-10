require_relative 'jahis_parser'

(1..11).each do |n|
  p n
  parser = JahisParser::Loader.new("sample_data/#{n}.csv")
  parser.exec
end
