require_relative 'value'

module JahisParser
  # to_hash の mixin 用
  # params に対して, to_value を適用して返す
  module Hashable
    def to_hash
      h = {}
      @params.each do |k, v|
        h[k] = v.respond_to?(:to_value) ? v.to_value : v
      end
      h
    end
  end

  module Row
    # バージョン情報
    class Version
      include Hashable
      def initialize(row)
        # バージョン情報チェック
        version = row[0]

        if version != 'JAHISTC07'
          raise "サポート外のバージョンです '#{version}'"
        end

        @params = {
          version: version,
          output_type: Value::OutputType.new(row[1]),
        }
      end
    end

    # (1) 患者情報レコード
    class PatientInfo
      include Hashable
      def initialize(row)
        @params = {
          # 患者氏名
          name: row[1],
          # 患者性別 （1:男 2:女）
          gender: Value::Gender.new(row[2]),
          # 患者生年月日
          birthday: Value::Date.new(row[3]),
          # 患者郵便番号
          zip_code: row[4],
          # 患者住所
          address: row[5],
          # 患者電話番号
          phone_number: row[6],
          # 緊急連絡先
          emergency_contact: row[7],
          # 血液型
          blood_type: row[8],
          # 体重
          body_weight: Value::Weight.new(row[9]),
          # 患者氏名カナ
          name_kana: row[10],
        }
      end
    end

    # (2) 患者特記レコード
    class PatientNote
      include Hashable
      def initialize(row)
        @params = {
          # 患者特記種別 （1:アレルギー歴 2:副作用歴 3：既往歴 9：その他）
          type: Value::PatientNoteType.new(row[1]),
          # 患者特記内容
          content: row[2],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[3]),
        }
      end
    end

    # (3) 一般用医薬品服用レコード
    class OtcDrug
      include Hashable
      def initialize(row)
        @params = {
          # 薬品名称
          name: row[1],
          # 服用開始年月日
          started_on: Value::Date.new(row[2]),
          # 服用終了年月日
          ended_on: Value::Date.new(row[3]),
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[4]),
        }
      end
    end

    # (4) 手帳メモレコード
    class Memo
      include Hashable
      def initialize(row)
        @params = {
          # 手帳メモ情報
          content: row[1],
          # メモ入力年月日
          entried_on: Value::Date.new(row[2]),
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[3]),
        }
      end
    end

    # (5) 調剤等年月日レコード
    class DispensedOn
      include Hashable
      def initialize(row)
        @params = {
          # 調剤等年月日
          date: Value::Date.new(row[1]),
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[2]),
        }
      end
    end

    # (11) 調剤－医療機関等レコード
    class DispensingFacility
      include Hashable
      def initialize(row)
        @params = {
          # 医療機関等名称
          name: row[1],
          # 医療機関等都道府県
          prefecture: Value::Prefecture.new(row[2]),
          # 医療機関等点数表 （1:医科 3:歯科 4:調剤）
          score_table: Value::ScoreTable.new(row[3]),
          # 医療機関等コード
          code: row[4],
          # 医療機関等郵便番号
          zip_code: row[5],
          # 医療機関等住所
          address: row[6],
          # 医療機関等電話番号
          phone_number: row[7],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[8]),
        }
      end
    end

    # (15) 調剤－医師・薬剤師レコード
    class DispensingDoctorPharmacist
      include Hashable
      def initialize(row)
        @params = {
          # 医師・薬剤師氏名
          name: row[1],
          # 医師・薬剤師連絡先
          contact: row[2],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[3]),
        }
      end
    end

    # (51) 処方－医療機関レコード
    class PrescriptionFacility
      include Hashable
      def initialize(row)
        @params = {
          # 医療機関名称
          name: row[1],
          # 医療機関都道府県
          prefecture: Value::Prefecture.new(row[2]),
          # 医療機関点数表 （1:医科 3:歯科）
          score_table: Value::ScoreTable.new(row[3]),
          # 医療機関コード
          code: row[4],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[5]),
        }
      end
    end

    # (55) 処方－医師レコード
    class Doctor
      include Hashable
      def initialize(row)
        @params = {
          # 医師氏名
          doctor_name: row[1],
          # 診療科名
          department_name: row[2],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[3]),
        }
      end
    end

    # (201) 薬品レコード
    class Medicine
      include Hashable
      def initialize(row)
        @params = {
          # 薬品名称
          name: row[2],
          # 用量
          dose: Value::Dose.new(row[3]),
          # 単位名
          unit: row[4],
          # 薬品コード種別
          code_type: row[5],
          # 薬品コード
          code: row[6],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[7]),
        }

        @supplement = []
        @dose_caution = []
      end

      def supplement(row)
        @supplement.push Supplement.new(row)
      end

      def dose_caution(row)
        @dose_caution.push DoseCaution.new(row)
      end

      # (281) 薬品補足レコード
      class Supplement
        include Hashable
        def initialize(row)
          @params = {
              # 内容
              content: row[2],
              # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
              author: Value::Author.new(row[3]),
          }
        end
      end

      # (291) 薬品服用注意レコード
      class DoseCaution
        include Hashable
        def initialize(row)
          @params = {
            # 内容
            content: row[2],
            # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
            author: Value::Author.new(row[3]),
          }
        end
      end
    end

    # (301) 用法情報
    class DosageAdministration
      include Hashable
      def initialize(row)
        @params = {
          # 用法名称
          name: row[2],
          # 調剤数量 (内服:投与日数、内滴:「1」固定、屯服:投与回数、外用:「1」固定、注射「1」固定、浸煎薬:投与日数、湯薬:投与日数、材料:「1」固定、その他:「1」固定)
          dispensing_quantity: row[3],
          # 調剤単位
          dispensing_unit: row[4],
          # 剤形コード (別表４)
          dosage_form_code: Value::DosageFormCode.new(row[5]),
          # 用法コード種別 (1:ｺｰﾄﾞなし 2:JAMI 用法ｺｰﾄ 3～:将来統一コードを想定)
          code_type: Value::DosageAdministrationCodeType.new(row[6]),
          # 用法コード
          code: row[7],
        }

        @supplement = []
      end

      def supplement(row)
        @supplement.push Supplement.new(row)
      end

      # (311) 用法補足レコード
      class Supplement
        include Hashable
        def initialize(row)
          @params = {
            # 内容
            content: row[2],
            # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
            author: Value::Author.new(row[3]),
          }
        end
      end
    end

    # (391) 処方服用注意レコード
    class RecipeDoseCaution
      include Hashable
      def initialize(row)
        @params = {
          # 内容
          content: row[2],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[3]),
        }
      end
    end

    # (401) 服用注意レコード
    class DoseCaution
      include Hashable
      def initialize(row)
        @params = {
          # 内容
          content: row[1],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[2]),
        }
      end
    end

    # (411) 医療機関等提供情報レコード
    class MedicalFacilityProviding
      include Hashable
      def initialize(row)
        @params = {
          # 内容
          content: row[1],
          # 提供情報種別
          providing_type: Value::ProvidingType.new(row[2]),
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[3]),
        }
      end
    end

    # (421) 残薬確認レコード
    class LeftoverMedicineConfirmation
      include Hashable
      def initialize(row)
        @params = {
          # 内容
          content: row[1],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[2]),
        }
      end
    end

    # (501) 備考レコード
    class Note
      include Hashable
      def initialize(row)
        @params = {
          # 内容
          content: row[1],
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[2]),
        }
      end
    end

    # (601) 患者等記入レコード
    class PatientEntry
      include Hashable
      def initialize(row)
        @params = {
          # 内容
          content: row[1],
          # 入力年月日
          entried_on: Value::Date.new(row[2]),
        }
      end
    end

    # (701) かかりつけ薬剤師レコード
    class Pharmacist
      include Hashable
      def initialize(row)
        @params = {
          # かかりつけ薬剤師氏名
          name: row[1],
          # 勤務先薬局名称
          pharmacy: row[2],
          # 連絡先
          contact: row[3],
          # 担当開始日
          started_on: Value::Date.new(row[4]),
          # 担当終了日
          ended_on: Value::Date.new(row[5]),
          # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
          author: Value::Author.new(row[6]),
        }
      end
    end
  end
end
