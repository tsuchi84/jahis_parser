module JahisParser
  module Value
    class Enum
      ENUM = {}.freeze

      def initialize(value)
        if value.nil?
          @value = nil
          return
        end

        @value = value.to_i
        unless self.class::ENUM.key?(@value)
          raise "#{@value} is not defined"
        end
      end

      def pretty_print(q)
        if @value.nil?
          q.pp nil
          return
        end

        q.pp "#{@value}:#{self.class::ENUM[@value]}"
      end
    end

    # レコード作成者
    class Author < Enum
      ENUM = {
        1 => '医療関係者',
        2 => '患者等',
        8 => 'その他',
        9 => '不明',
      }.freeze
    end

    # 性別
    class Gender < Enum
      ENUM = {
        1 => '男',
        2 => '女',
      }.freeze
    end

    # 患者特記種別
    class PatientNoteType < Enum
      ENUM = {
        1 => 'アレルギー歴',
        2 => '副作用歴',
        3 => '既往歴',
        9 => 'その他',
      }.freeze
    end

    # 都道府県
    class Prefecture < Enum
      ENUM = {
        1 => '北海道',
        2 => '青森',
        3 => '岩手',
        4 => '宮城',
        5 => '秋田',
        6 => '山形',
        7 => '福島',
        8 => '茨城',
        9 => '栃木',
        10 => '群馬',
        11 => '埼玉',
        12 => '千葉',
        13 => '東京',
        14 => '神奈川',
        15 => '新潟',
        16 => '富山',
        17 => '石川',
        18 => '福井',
        19 => '山梨',
        20 => '長野',
        21 => '岐阜',
        22 => '静岡',
        23 => '愛知',
        24 => '三重',
        25 => '滋賀',
        26 => '京都',
        27 => '大阪',
        28 => '兵庫',
        29 => '奈良',
        30 => '和歌山',
        31 => '鳥取',
        32 => '島根',
        33 => '岡山',
        34 => '広島',
        35 => '山口',
        36 => '徳島',
        37 => '香川',
        38 => '愛媛',
        39 => '高知',
        40 => '福岡',
        41 => '佐賀',
        42 => '長崎',
        43 => '熊本',
        44 => '大分',
        45 => '宮崎',
        46 => '鹿児島',
        47 => '沖縄',
      }.freeze
    end

    class ScoreTable < Enum
      ENUM = {
        1 => '医科',
        3 => '歯科',
        4 => '調剤',
      }.freeze
    end

    class Date
      def initialize(value)
        @value = value
        # TODO 和暦対応の日付をパースする
        # TODO nil も許可する
      end
    end

    # 体重
    class Weight
      def initialize(value)
        @value = value.to_f
      end
    end

  end
end
