
module JahisParser
  class StateError < StandardError
    def initialize(msg = nil, number = nil)
      super("#{msg} (current:#{number})")
    end
  end

  # レコードの登場順番をレコードNoからチェックする
  class State
    def initialize
      @number = 0
      @history = []
    end

    def set(number)
      case number
      when 1
        if @number != 0
          raise StateError.new('患者情報レコード(1)は、先頭にしか出力できません', @number)
        end
      when 2
        if @number > 2
          raise StateError.new('患者特記レコード(2)は、先頭かレコードNo1,2のいずれかに続いている必要があります', @number)
        end
      when 3
        if @number > 3
          raise StateError.new('一般用医薬品服用レコード(3)は、先頭かレコードNo1,2,3のいずれかに続いている必要があります', @number)
        end
      when 4
        if @number > 4
          raise StateError.new('手帳メモレコード(4)は、先頭かレコードNo1,2,3,4のいずれかに続いている必要があります', @number)
        end
      when 5
        if @number >= 5 && @number < 301
          raise StateError.new('調剤等年月日レコード(5)は、レコードNoが4以下か、301以降である必要があります', @number)
        end
      when 11
        if @number != 5
          raise StateError.new('調剤－医療機関等レコード(11)は、レコードNo5に続いている必要があります', @number)
        end
      when 15
        if @number != 11
          raise StateError.new('調剤－医師・薬剤師レコード(15)は、レコードNo11に続いている必要があります', @number)
        end
      when 51
        if @number != 11 && @number != 15
          raise StateError.new('処方－医療機関レコード(51)は、レコードNo1xのいずれかに続いている必要があります', @number)
        end
      when 55
        if @number != 51 && @number != 55
          raise StateError.new('処方－医師レコード(55)は、レコードNo5xのいずれかに続いている必要があります', @number)
        end
      when 201
        if @number != 51 && @number != 55
          if @number < 301 || @number > 391
            raise StateError.new('薬品レコード(201)は、レコードNo5x,3xxのいずれかに続いている必要があります', @number)
          end
        end
      when 281
        if @number != 201 && @number != 281
          raise StateError.new('薬品補足レコード(281)は、レコードNo201,281のいずれかに続いている必要があります', @number)
        end
      when 291
        if @number != 201 && @number != 281 && @number != 291
          raise StateError.new('薬品補足レコード(281)は、レコードNo201,281,291のいずれかに続いている必要があります', @number)
        end
      when 301
        if @number < 201 || @number > 291
          raise StateError.new('用法レコード(301)は、レコードNo2xxのいずれかに続いている必要があります', @number)
        end
      when 311
        if @number != 301 && @number != 311
          raise StateError.new('用法補足レコード(311)は、レコードNo301,311のいずれかに続いている必要があります', @number)
        end
        # TODO 391以降
      else
        # raise StateError.new("未定義のレコードNoです:#{number}", @number)
      end

      @history.push number
      @number = number
    end

    # TODO 新規の調剤情報を追加する状態になったかなどの判定を @number の動きで判定するロジックの追加

    # TODO 調剤年月日レコード(5)が新規に発生した状態だったらtrue

  end
end