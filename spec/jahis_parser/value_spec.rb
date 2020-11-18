require_relative '../../jahis_parser/value'

class ExampleEnum < JahisParser::Value::Enum
  ENUM = {
    1 => 'A',
    2 => 'B',
  }.freeze
end

RSpec.describe JahisParser::Value::Enum do
  let(:value) { '1' }
  let(:enum) { ExampleEnum.new(value) }

  describe '#to_value' do
    it 'string が int になる' do
      expect(enum.to_value).to eq 1
    end
  end

  describe '#to_s' do
    it '返却値の確認' do
      expect(enum.to_s).to eq 'A'
    end
  end

  describe 'raise' do
    let(:value) { '3' }
    it '存在しないvalue' do
      expect{ enum }.to raise_error '3 is not defined'
    end
  end
end

RSpec.describe JahisParser::Value::Date do
  let(:input) { '20201115' }
  let(:date) { JahisParser::Value::Date.new(input) }

  describe '#new' do
    context '正常な数字8桁の場合' do
      it 'to_date' do
        expect(date.to_date).to eq Date.new(2020, 11, 15)
      end

      it 'to_value' do
        expect(date.to_value).to eq '20201115'
      end
    end

    context '異常な数値8桁の場合' do
      let(:input) { '20200230' }
      it '2月30日' do
        expect {date}.to raise_error 'invalid date'
      end
    end

    context '元号' do
      context '昭和の場合' do
        let(:input) { 'S571115' }
        it '適切なDateに一致すること' do
          expect(date.to_date).to eq Date.new(1982, 11, 15)
        end
      end
      context '令和の場合' do
        let(:input) { 'R021115' }
        it '適切なDateに一致すること' do
          expect(date.to_date).to eq Date.new(2020, 11, 15)
        end
      end
      context '範囲を外れた年の場合' do
        let(:input) { 'S991115' }
        it '正常な日付になること' do
          expect(date.to_date).to eq Date.new(2024, 11, 15)
        end
      end

      context '大正の場合' do
        let(:input) { 'T011115' }
        it '適切なDateに一致すること' do
          expect(date.to_date).to eq Date.new(1912, 11, 15)
        end
      end

      context '明治の場合' do
        let(:input) { 'M451115' }
        it '適切なDateに一致すること' do
          expect(date.to_date).to eq Date.new(1912, 11, 15)
        end
      end

      context '未定義の元号の場合' do
        let(:input) { 'A011115' }
        it 'raiseされること' do
          expect {date}.to raise_error 'invalid date format \'A011115\''
        end
      end
    end

    context 'nilの場合' do
      let(:input) { nil }

      it 'to_dateがnilを返す' do
        expect(date.to_date).to eq nil
      end

      it 'to_valueがnilを返す' do
        expect(date.to_value).to eq nil
      end
    end
  end
end

RSpec.describe JahisParser::Value::Weight do
  describe '#new' do
    let(:weight) { JahisParser::Value::Weight.new(value) }
    context '正常な数値の文字列の場合' do
      let(:value) { '56.7' }
      it '数値化されて取得できる' do
        expect(weight.to_value).to eq 56.7
      end
    end

    context '数値を含まない文字列の場合' do
      let(:value) { 'FOO' }
      it 'エラーにならずにnilになる' do
        expect(weight.to_value).to eq nil
      end
    end
  end
end

RSpec.describe JahisParser::Value::Dose do
  describe '#new' do
    let(:weight) { JahisParser::Value::Dose.new(value) }
    context '正常な数値の文字列の場合' do
      let(:value) { '1' }
      it '数値化されて取得できる' do
        expect(weight.to_value).to eq 1
      end
    end

    context '数値を含まない文字列の場合' do
      let(:value) { 'FOO' }
      it 'エラーにならずに nil になる' do
        expect(weight.to_value).to eq nil
      end
    end
  end
end

RSpec.describe JahisParser::Value::DispensingQuantity do
  describe '#new' do
    let(:weight) { JahisParser::Value::DispensingQuantity.new(value) }
    context '正常な数値の文字列の場合' do
      let(:value) { '1' }
      it '数値化されて取得できる' do
        expect(weight.to_value).to eq 1
      end
    end

    context '数値を含まない文字列の場合' do
      let(:value) { 'FOO' }
      it 'エラーにならずに nil になる' do
        expect(weight.to_value).to eq nil
      end
    end
  end
end
