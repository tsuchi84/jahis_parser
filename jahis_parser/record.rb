require_relative 'row'

module JahisParser
  class Record
    def initialize(row)
      @version = Row::Version.new(row)
      @patient_info = nil
      @patient_note = []
      @otc_drug = []
      @memo = []
      @dispensing_info = []
      @pharmacist = []
    end

    # レコードの作成
    def set(number, row)
      case number
      when 1
        # (1) 患者情報レコード
        @patient_info = Row::PatientInfo.new(row)
      when 2
        # (2) 患者特記レコード
        @patient_note.push Row::PatientNote.new(row)
      when 3
        # (3) 一般用医薬品服用レコード
        @otc_drug.push Row::OtcDrug.new(row)
      when 4
        # (4) 手帳メモレコード
        @memo.push Row::Memo.new(row)
      when 5
        # (5) 調剤等年月日レコード
        info = DispensingInfo.new
        @dispensing_info.push info
        info.set number, row
      when 11, 15, 51, 55, 201, 281, 291, 301, 311, 391, 401, 411, 421, 501, 601
        raise '@dispensing_info is empty' if @dispensing_info.empty?

        # dispensing_info 以下のものは処理を委譲する
        @dispensing_info.last.set number, row
      when 701
        # (701) かかりつけ薬剤師レコード
        @pharmacist.push Row::Pharmacist.new(row)
      else
        raise "undefined number #{number}"
      end
    end

    # 調剤情報
    # noinspection RubyTooManyInstanceVariablesInspection
    class DispensingInfo
      def initialize
        @dispensed_on = nil
        @dispensing_facility = nil
        @dispensing_doctor_pharmacist = nil
        @prescription_facility = nil
        @prescription = []
        @dose_caution = []
        @medical_facility_providing = []
        @leftover_medicine_confirmation = []
        @note = []
        @patient_entry = []
      end

      def set(number, row)
        case number
        when 5
          # (5) 調剤等年月日レコード
          @dispensed_on = Row::DispensedOn.new(row)
        when 11
          # (11) 調剤－医療機関等レコード
          @dispensing_facility = Row::DispensingFacility.new(row)
        when 15
          # (15) 調剤－医師・薬剤師レコード
          @dispensing_doctor_pharmacist = Row::DispensingDoctorPharmacist.new(row)
        when 51
          # (51) 処方－医療機関レコード
          @prescription_facility = Row::PrescriptionFacility.new(row)
        when 55
          # (55) 処方－医師レコード
          # このレコードが入ってきた場合パターン1となり prescription 以下のレコードが複数件になる可能性がある
          prescription = Prescription.new
          @prescription.push prescription
          prescription.set number, row
        when 201, 281, 291, 301, 311, 391
          if @prescription.empty?
            @prescription.push Prescription.new
          end

          @prescription.last.set number, row
        when 401
          # (401) 服用注意レコード
          @dose_caution.push Row::DoseCaution.new(row)
        when 411
          # (411) 医療機関等提供情報レコード
          @medical_facility_providing.push Row::MedicalFacilityProviding.new(row)
        when 421
          # (421) 残薬確認レコード
          @leftover_medicine_confirmation.push Row::LeftoverMedicineConfirmation.new(row)
        when 501
          # (501) 備考レコード
          @note.push Row::Note.new(row)
        when 601
          # (601) 患者等記入レコード
          @patient_entry.push Row::PatientEntry.new(row)
        else
          raise "undefined number #{number}"
        end
      end

      # 処方－医師
      class Prescription
        def initialize
          @doctor = nil
          @recipe = []
        end

        def set(number, row)
          case number
          when 55
            # (55) 処方－医師レコード
            @doctor = Row::Doctor.new(row)
          when 201, 281, 291, 301, 311, 391
            # RP 毎の Recipe レコードの作成
            rp = row.shift.to_i
            recipe = recipe(rp)

            if recipe.nil?
              recipe = Recipe.new(rp)
              @recipe.push recipe
            end

            recipe.set number, row
          else
            raise "undefined number #{number}"
          end
        end

        # rp から recipe を特定
        def recipe(rp)
          index = @recipe.index{|r| r.number == rp}
          return nil if index.nil?

          @recipe[index]
        end

        # RP 毎のレコードを保持
        class Recipe
          attr :number

          def initialize(rp)
            @number = rp
            @medicine = []
            @dosage_administration = nil
            @dose_caution = []
          end

          def set(number, row)
            case number
            when 201
              # (201) 薬品レコード
              @medicine.push Row::Medicine.new(row)
            when 281
              # (281) 薬品補足レコード
              raise '@medicine is empty' if @medicine.empty?

              @medicine.last.supplement row
            when 291
              # (291) 薬品服用注意レコード
              raise '@medicine is empty' if @medicine.empty?

              @medicine.last.dose_caution row
            when 301
              # (301) 用法情報
              @dosage_administration = Row::DosageAdministration.new(row)
            when 311
              # (311) 用法補足レコード
              raise '@dosage_administration is nil' if @dosage_administration.nil?

              @dosage_administration.supplement row
            when 391
              # (391) 処方服用注意レコード
              @dose_caution.push Row::RecipeDoseCaution.new(row)
            else
              raise "undefined number #{number}"
            end
          end
        end
      end
    end
  end
end