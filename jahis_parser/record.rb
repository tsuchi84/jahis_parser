require_relative 'value'
require_relative 'state'

module JahisParser
  class Record
    def initialize(row)
      @version = Version.new(row)
      @patient_info = nil
      @patient_note = nil
      @otc_drug = nil
      @memo = nil
      @dispensing_info = nil
      @pharmacist = nil

      @state = State.new
    end

    def state(number)
      @state.set number
    end

    def patient_info(row)
      @patient_info = PatientInfo.new row
    end

    def patient_note(row)
      if @patient_note.nil?
        @patient_note = PatientNote.new row
      else
        @patient_note.append row
      end
    end

    def otc_drug(row)
      if @otc_drug.nil?
        @otc_drug = OtcDrug.new row
      else
        @otc_drug.append row
      end
    end

    def memo(row)
      if @memo.nil?
        @memo = Memo.new row
      else
        @memo.append row
      end
    end

    # 調剤情報
    # (5) 調剤等年月日レコードを受け渡したら新規レコードを作成する
    def dispensing_info(row = nil)
      return @dispensing_info if row.nil?

      if @dispensing_info.nil?
        @dispensing_info = DispensingInfo.new row
      else
        @dispensing_info.append row
      end
    end

    # (701) かかりつけ薬剤師レコード
    def pharmacist(row)
      if @pharmacist.nil?
        @pharmacist = Pharmacist.new row
      else
        @pharmacist.append row
      end
    end

    # バージョン情報
    class Version
      def initialize(row)
        # TODO バージョン情報チェック
        @params = {
          version: row[0],
          output: row[1], # TODO enum
        }
      end
    end

    # (1) 患者情報レコード
    class PatientInfo
      def initialize(row)
        @params = {
          # 患者氏名
          name: row[0],
          # 患者性別 （1:男 2:女）
          gender: Value::Gender.new(row[1]),
          # 患者生年月日
          birthday: Value::Date.new(row[2]),
          # 患者郵便番号
          zip_code: row[3],
          # 患者住所
          address: row[4],
          # 患者電話番号
          phone_number: row[5],
          # 緊急連絡先
          emergency_contact: row[6],
          # 血液型
          blood_type: row[7],
          # 体重
          body_weight: Value::Weight.new(row[8]),
          # 患者氏名カナ
          name_kana: row[9],
        }
      end
    end

    # (2) 患者特記レコード
    class PatientNote
      def initialize(row)
        @records = []
        append row
      end

      def append(row)
        @records.push Item.new(row)
      end

      class Item
        def initialize(row)
          @params = {
            # 患者特記種別 （1:アレルギー歴 2:副作用歴 3：既往歴 9：その他）
            type: Value::PatientNoteType.new(row[0]),
            # 患者特記内容
            content: row[1],
            # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
            author: Value::Author.new(row[2]),
          }
        end
      end
    end

    # (3) 一般用医薬品服用レコード
    class OtcDrug
      def initialize(row)
        @records = []
        append row
      end

      def append(row)
        @records.push Item.new(row)
      end

      class Item
        def initialize(row)
          @parmas = {
            # 薬品名称
            name: row[0],
            # 服用開始年月日
            started_on: Value::Date.new(row[1]),
            # 服用終了年月日
            ended_on: Value::Date.new(row[2]),
            # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
            author: Value::Author.new(row[3]),
          }
        end
      end
    end

    # (4) 手帳メモレコード
    class Memo
      def initialize(row)
        @records = []
        append row
      end

      def append(row)
        @records.push Item.new(row)
      end

      class Item
        def initialize(row)
          @params = {
            # 手帳メモ情報
            content: row[0],
            # メモ入力年月日
            entried_on: Value::Date.new(row[1]),
            # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
            author: Value::Author.new(row[2]),
          }
        end
      end
    end

    # 調剤情報
    class DispensingInfo
      def initialize(row)
        @records = []
        append row
      end

      def append(row)
        @records.push Item.new(row)
      end

      def last
        @records.last
      end

      class Item
        def initialize(row)
          @dispensed_on = DispensedOn.new(row)
          @dispensing_facility = nil
          @dispensing_doctor_pharmacist = nil
          @prescription_facility = nil
        end

        # (11) 調剤－医療機関等レコード
        def dispensing_facility(row)
          if @dispensing_facility.nil?
            @dispensing_facility = DispensingFacility.new row
          else
            raise 'dispensing_facility has already been initialized'
          end
        end

        # (15) 調剤－医師・薬剤師レコード
        def dispensing_doctor_pharmacist(row)
          if @dispensing_doctor_pharmacist.nil?
            @dispensing_doctor_pharmacist = DispensingDoctorPharmacist.new row
          else
            raise 'dispensing_doctor_pharmacist has already been initialized'
          end
        end

        # (51) 処方－医療機関レコード
        def prescription_facility(row)
          if @prescription_facility.nil?
            @prescription_facility = PrescriptionFacility.new row
          else
            raise 'prescription_facility has already been initialized'
          end
        end

        # (11) 調剤－医療機関等レコード
        class DispensingFacility
          def initialize(row)
            @params = {
              # 医療機関等名称
              name: row[0],
              # 医療機関等都道府県
              prefecture: Value::Prefecture.new(row[1]),
              # 医療機関等点数表 （1:医科 3:歯科 4:調剤）
              score_table: Value::ScoreTable.new(row[2]),
              # 医療機関等コード
              code: row[3],
              # 医療機関等郵便番号
              zip_code: row[4],
              # 医療機関等住所
              address: row[5],
              # 医療機関等電話番号
              phone_number: row[6],
              # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
              author: Value::Author.new(row[7]),
            }
          end
        end

        # (15) 調剤－医師・薬剤師レコード
        class DispensingDoctorPharmacist
          def initialize(row)
            @params = {
              # 医師・薬剤師氏名
              name: row[0],
              # 医師・薬剤師連絡先
              contact: row[1],
              # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
              author: Value::Author.new(row[2]),
            }
          end
        end

        # (51) 処方－医療機関レコード
        class PrescriptionFacility
          def initialize(row)
            @params = {
              # 医療機関名称
              name: row[0],
              # 医療機関都道府県
              prefecture: Value::Prefecture.new(row[1]),
              # 医療機関点数表 （1:医科 3:歯科）
              score_table: Value::ScoreTable.new(row[2]),
              # 医療機関コード
              code: row[3],
              # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
              author: Value::Author.new(row[4]),
            }
          end
        end
      end

      # (5) 調剤等年月日レコード
      class DispensedOn
        def initialize(row)
          @params = {
            # 調剤等年月日
            date: Value::Date.new(row[0]),
            # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
            author: Value::Author.new(row[1]),
          }
        end
      end
    end

    # (701) かかりつけ薬剤師レコード
    class Pharmacist
      def initialize(row)
        @records = []
        append row
      end

      def append(row)
        @records.push Item.new(row)
      end

      class Item
        def initialize(row)
          @params = {
            # かかりつけ薬剤師氏名
            name: row[0],
            # 勤務先薬局名称
            pharmacy: row[1],
            # 連絡先
            contact: row[2],
            # 担当開始日
            started_on: Value::Date.new(row[3]),
            # 担当終了日
            ended_on: Value::Date.new(row[4]),
            # レコード作成者 （1: 医療関係者 2:患者等 8:その他 9:不明）
            author: Value::Author.new(row[5]),
          }
        end
      end
    end
  end

  # Patient
  class Patient
  end
end