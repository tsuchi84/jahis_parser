require_relative '../../jahis_parser/row'

class HashableClass
  include JahisParser::Hashable

  def initialize
    @params = {
      A: ToValueClass.new,
      B: 2
    }
  end
end

class ToValueClass
  def to_value
    1
  end
end

RSpec.describe JahisParser::Hashable do
  describe '#to_hash' do
    it '下位の#to_valueが呼ばれた結果になっていること' do
      expect(HashableClass.new.to_hash).to include({A: 1, B: 2})
    end
  end
end
