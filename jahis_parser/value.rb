require 'date'

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

      def to_value
        @value
      end

      def to_s
        self.class::ENUM[@value]
      end

      def pretty_print(q)
        if @value.nil?
          q.pp nil
          return
        end

        q.pp "#{@value}:#{self.class::ENUM[@value]}"
      end
    end

    # 出力区分
    class OutputType < Enum
      ENUM = {
        1 => '医療機関・薬局から患者等に情報を提供する場合',
        2 => '患者等から医療機関・薬局に情報を提供する場合',
      }.freeze
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

    # 医療機関等点数表
    class ScoreTable < Enum
      ENUM = {
        1 => '医科',
        3 => '歯科',
        4 => '調剤',
      }.freeze
    end

    # 提供情報種別
    class ProvidingType < Enum
      ENUM = {
        30 => '入院中に副作用が発現した薬剤に関する情報',
        31 => '退院後の療養を担う保険医療機関での投薬又は保険薬局での調剤に必要な服薬の状況及び投薬上の工夫に関する情報',
        99 => 'その他',
      }.freeze
    end

    # 剤形コード (別表４)
    class DosageFormCode < Enum
      ENUM = {
        1 => '内服',
        2 => '内滴',
        3 => '屯服',
        4 => '注射',
        5 => '外用',
        6 => '浸煎',
        7 => '湯',
        9 => '材料',
        10 => 'その他',
      }.freeze
    end

    # 用法コード種別
    class DosageAdministrationCodeType < Enum
      ENUM = {
        1 => 'ｺｰﾄﾞなし',
        2 => 'JAMI 用法ｺｰﾄﾞ',
        3 => '将来統一コードを想定',
      }.freeze
    end

    # 和暦対応の日付
    class Date
      JAPANESE_CALENDAR_OFFSET = {
        'M' => 1867, # M 明治
        'T' => 1911, # T 大正
        'S' => 1925, # S 昭和
        'H' => 1988, # H 平成
        'R' => 2018, # R 令和
      }.freeze

      def initialize(value)
        @original = value

        case value
        when nil
          @value = nil
        when /^\d{8}$/
          # YYYYMMDD
          @value = ::Date.strptime(value, '%Y%m%d')
        when /^([MTSHR])(\d{2})(\d{2})(\d{2})$/
          # GYYMMDD
          y = JAPANESE_CALENDAR_OFFSET[$1] + $2.to_i

          @value = ::Date.strptime("#{y}#{$3}#{$4}", '%Y%m%d')
        else
          raise "invalid date format '#{value}'"
        end
      end

      def to_value
        @value&.strftime('%Y%m%d')
      end

      def to_date
        @value
      end
    end

    # 体重
    class Weight
      def initialize(value)
        @value = value.to_f
      end

      def to_value
        @value
      end
    end

    # 用量
    class Dose
      def initialize(value)
        @value = value.to_f
      end

      def to_value
        @value
      end
    end
  end
end
