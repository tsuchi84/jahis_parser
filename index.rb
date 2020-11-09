require_relative 'jahis_parser'

parser = JahisParser::Loader.new('sample_data/11.csv')
parser.exec
