require_relative '../../jahis_parser/record'
require 'csv'
require 'json'

RSpec.describe JahisParser::Record do
  describe 'parse' do
    def csv(file)
      rows = CSV.read(File.dirname(__FILE__) + '/csv/' + file)
      record = JahisParser::Record.new(rows.shift)
      rows.each { |row| record.set row }
      record.to_hash
    end

    def json(file)
      string = File.read(File.dirname(__FILE__) + '/json/' + file)
      JSON.parse(string, symbolize_names: true)
    end

    context 'パターン1' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('1.csv')).to include(json('1.json'))
      end
    end

    context 'パターン2' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('2.csv')).to include(json('2.json'))
      end
    end

    context 'パターン3' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('3.csv')).to include(json('3.json'))
      end
    end

    context 'パターン4' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('4.csv')).to include(json('4.json'))
      end
    end

    context 'パターン5' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('5.csv')).to include(json('5.json'))
      end
    end

    context 'パターン6' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('6.csv')).to include(json('6.json'))
      end
    end

    context 'パターン7' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('7.csv')).to include(json('7.json'))
      end
    end

    context 'パターン8' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('8.csv')).to include(json('8.json'))
      end
    end

    context 'パターン9' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('9.csv')).to include(json('9.json'))
      end
    end

    context 'パターン10' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('10.csv')).to include(json('10.json'))
      end
    end

    context 'パターン11' do
      it 'CSV から hash への変換結果を検証する' do
        expect(csv('11.csv')).to include(json('11.json'))
      end
    end
  end
end
