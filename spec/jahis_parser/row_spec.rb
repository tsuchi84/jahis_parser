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

RSpec.describe JahisParser::Row::Version do
  describe '#new' do
    let(:row) { JahisParser::Row::Version.new(csv.split(/,/)) }
    context 'サポート内のバージョン情報' do
      let(:csv) { 'JAHISTC07,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({version: 'JAHISTC07', output_type: 1})
      end
    end

    context 'サポート外のバージョン情報' do
      let(:csv) { 'JAHISTC01,1' }
      it 'raiseされること' do
        expect{row}.to raise_error "サポート外のバージョンです 'JAHISTC01'"
      end
    end
  end
end

RSpec.describe JahisParser::Row::PatientInfo do
  describe '#new' do
    let(:row) { JahisParser::Row::PatientInfo.new(csv.split(/,/)) }
    context '正常なデータ' do
      let(:csv) { '1,鈴木 一郎,1,S330303,105-0004,東京都港区新橋1丁目1番 ○×ビル 5階,03-1234-1234,鈴木 花子 03-2345-2345,Ｂ＋,63.7,スズキ　タロウ' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: '鈴木 一郎',
                                         gender: 1,
                                         birthday: '19580303',
                                         zip_code: '105-0004',
                                         address: '東京都港区新橋1丁目1番 ○×ビル 5階',
                                         phone_number: '03-1234-1234',
                                         emergency_contact: '鈴木 花子 03-2345-2345',
                                         blood_type: 'Ｂ＋',
                                         body_weight: 63.7,
                                         name_kana: 'スズキ　タロウ'
                                       })
      end
    end
    context '最低限のデータ' do
      let(:csv) { '1,鈴木 花子,2,S570303,,,,,,,' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: '鈴木 花子',
                                         gender: 2,
                                         birthday: '19820303',
                                         zip_code: nil,
                                         address: nil,
                                         phone_number: nil,
                                         emergency_contact: nil,
                                         blood_type: nil,
                                         body_weight: nil,
                                         name_kana: nil
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::PatientNote do
  describe '#new' do
    let(:row) { JahisParser::Row::PatientNote.new(csv.split(/,/)) }
    context '正常なデータ(1)' do
      let(:csv) { '2,3,狭心症（2011 年～),1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         type: 3,
                                         content: '狭心症（2011 年～)',
                                         author: 1
                                       })
      end
    end
    context '正常なデータ(2)' do
      let(:csv) { '2,9,嚥下困難のため、口腔内崩壊錠を使用する,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         type: 9,
                                         content: '嚥下困難のため、口腔内崩壊錠を使用する',
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::OtcDrug do
  describe '#new' do
    let(:row) { JahisParser::Row::OtcDrug.new(csv.split(/,/)) }
    context '正常なデータ' do
      let(:csv) { '3,バファリンＡ,20160411,20160411,2' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: 'バファリンＡ',
                                         started_on: '20160411',
                                         ended_on: '20160411',
                                         author: 2
                                       })
      end
    end
    context '最低限のデータ' do
      let(:csv) { '3,バファリンＡ,,,2' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: 'バファリンＡ',
                                         started_on: nil,
                                         ended_on: nil,
                                         author: 2
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::Memo do
  describe '#new' do
    let(:row) { JahisParser::Row::Memo.new(csv.split(/,/)) }
    context '正常なデータ' do
      let(:csv) { '4,予防接種を受けた,H280411,2' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         content: '予防接種を受けた',
                                         entried_on: '20160411',
                                         author: 2
                                       })
      end
    end
    context '最低限のデータ' do
      let(:csv) { '4,予防接種を受けた,,2' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         content: '予防接種を受けた',
                                         entried_on: nil,
                                         author: 2
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::DispensedOn do
  describe '#new' do
    let(:row) { JahisParser::Row::DispensedOn.new(csv.split(/,/)) }
    context '西暦' do
      let(:csv) { '5,20160411,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         date: '20160411',
                                         author: 1
                                       })
      end
    end
    context '和暦' do
      let(:csv) { '5,H280411,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         date: '20160411',
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::DispensingFacility do
  describe '#new' do
    let(:row) { JahisParser::Row::DispensingFacility.new(csv.split(/,/)) }
    context '正常なデータ' do
      let(:csv) { '11, 株 式 会 社 工 業 会 薬 局 駅 前 店,13,4,1234567,105-0004, 東京都港区新橋 1 丁目 11 番 ○×ビル 5 階,03-3456-3456,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: ' 株 式 会 社 工 業 会 薬 局 駅 前 店',
                                         prefecture: 13,
                                         score_table: 4,
                                         code: '1234567',
                                         zip_code: '105-0004',
                                         address: ' 東京都港区新橋 1 丁目 11 番 ○×ビル 5 階',
                                         phone_number: '03-3456-3456',
                                         author: 1
                                       })
      end
    end
    context '最低限のデータ' do
      let(:csv) { '11, 株 式 会 社 工 業 会 薬 局 駅 前 店,13,4,1234567,,,,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: ' 株 式 会 社 工 業 会 薬 局 駅 前 店',
                                         prefecture: 13,
                                         score_table: 4,
                                         code: '1234567',
                                         zip_code: nil,
                                         address: nil,
                                         phone_number: nil,
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::DispensingDoctorPharmacist do
  describe '#new' do
    let(:row) { JahisParser::Row::DispensingDoctorPharmacist.new(csv.split(/,/)) }
    context '正常なデータ' do
      let(:csv) { '15,工業会 次郎,03-4567-4567,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: '工業会 次郎',
                                         contact: '03-4567-4567',
                                         author: 1
                                       })
      end
    end
    context '最低限のデータ' do
      let(:csv) { '15,工業会 次郎,,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: '工業会 次郎',
                                         contact: nil,
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::PrescriptionFacility do
  describe '#new' do
    let(:row) { JahisParser::Row::PrescriptionFacility.new(csv.split(/,/)) }
    context '正常なデータ' do
      let(:csv) { '51,医療法人 工業会病院,13,1,1234567,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: '医療法人 工業会病院',
                                         prefecture: 13,
                                         score_table: 1,
                                         code: '1234567',
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::Doctor do
  describe '#new' do
    let(:row) { JahisParser::Row::Doctor.new(csv.split(/,/)) }
    context '正常なデータ' do
      let(:csv) { '55,工業会 次郎,内科,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         doctor_name: '工業会 次郎',
                                         department_name: '内科',
                                         author: 1
                                       })
      end
    end
    context '最低限のデータ' do
      let(:csv) { '55,工業会 次郎,,1' }
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         doctor_name: '工業会 次郎',
                                         department_name: nil,
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::Medicine do
  let(:row) { JahisParser::Row::Medicine.new(csv.split(/,/)) }
  let(:csv) { '201,1, 重 カ マ 「 ヨ シ ダ 」 ,1,ｇ,2,610409004,1' }
  describe '#new' do
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: ' 重 カ マ 「 ヨ シ ダ 」 ',
                                         dose: 1,
                                         unit: 'ｇ',
                                         code_type: 2,
                                         code: '610409004',
                                         author: 1
                                       })
      end
    end
  end

  describe '#supplement' do
    context 'Supplement の CSV を受け渡した場合' do
      it '階層の hash に値が設定されること' do
        row.supplement('281,1,朝 1 錠、夕 2 錠,1'.split(/,/))
        expect(row.to_hash).to include({
                                         supplement: [{
                                           content: '朝 1 錠、夕 2 錠',
                                           author: 1
                                         }]
                                       })
      end
      it '複数受け渡した場合、複数設定されること' do
        row.supplement('281,1,朝 1 錠、夕 2 錠,1'.split(/,/))
        row.supplement('281,1,粉砕,1'.split(/,/))
        expect(row.to_hash).to include({
                                         supplement: [{
                                           content: '朝 1 錠、夕 2 錠',
                                           author: 1
                                         },{
                                           content: '粉砕',
                                           author: 1
                                         }]
                                       })
      end
    end
  end

  describe '#dose_caution' do
    context 'DoseCaution の CSV を受け渡した場合' do
      it '階層の hash に値が設定されること' do
        row.dose_caution('291,1,グレープフルーツジュースと一緒に飲まないでください。,1'.split(/,/))
        expect(row.to_hash).to include({
                                         dose_caution: [{
                                           content: 'グレープフルーツジュースと一緒に飲まないでください。',
                                           author: 1
                                         }]
                                       })
      end
      it '複数受け渡した場合、複数設定されること' do
        row.dose_caution('291,1,グレープフルーツジュースと一緒に飲まないでください。,1'.split(/,/))
        row.dose_caution('291,1,患部を清潔にし、適量を塗ってください。,1 '.split(/,/))
        expect(row.to_hash).to include({
                                         dose_caution: [{
                                           content: 'グレープフルーツジュースと一緒に飲まないでください。',
                                           author: 1
                                         },{
                                           content: '患部を清潔にし、適量を塗ってください。',
                                           author: 1
                                         }]
                                       })
      end
    end
  end

  describe JahisParser::Row::Medicine::Supplement do
    let(:row) { JahisParser::Row::Medicine::Supplement.new(csv.split(/,/)) }
    describe '#new' do
      let(:csv) { '281,1,朝 1 錠、夕 2 錠,1' }
      context '正常なデータ' do
        it '正常に取り込めること' do
          expect(row.to_hash).to include({
                                           content: '朝 1 錠、夕 2 錠',
                                           author: 1
                                         })
        end
      end
    end
  end

  describe JahisParser::Row::Medicine::DoseCaution do
    let(:row) { JahisParser::Row::Medicine::DoseCaution.new(csv.split(/,/)) }
    describe '#new' do
      let(:csv) { '291,1,グレープフルーツジュースと一緒に飲まないでください。,1 ' }
      context '正常なデータ' do
        it '正常に取り込めること' do
          expect(row.to_hash).to include({
                                           content: 'グレープフルーツジュースと一緒に飲まないでください。',
                                           author: 1
                                         })
        end
      end
    end
  end
end

RSpec.describe JahisParser::Row::DosageAdministration do
  let(:row) { JahisParser::Row::DosageAdministration.new(csv.split(/,/)) }
  let(:csv) { '301,1,毎食後服用,3,日分,1,1,,1 ' }
  describe '#new' do
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: '毎食後服用',
                                         dispensing_quantity: 3,
                                         dispensing_unit: '日分',
                                         dosage_form_code: 1,
                                         code_type: 1,
                                         code: nil,
                                         author: 1
                                       })
      end
    end
  end

  describe '#supplement' do
    context 'Supplement の CSV を受け渡した場合' do
      it '階層の hash に値が設定されること' do
        row.supplement('311,1,ＲＰ１服用後,1'.split(/,/))
        expect(row.to_hash).to include({
                                         supplement: [{
                                           content: 'ＲＰ１服用後',
                                           author: 1
                                         }]
                                       })
      end
      it '複数受け渡した場合、複数設定されること' do
        row.supplement('311,1,ＲＰ１服用後,1'.split(/,/))
        row.supplement('311,1,一包化,1'.split(/,/))
        expect(row.to_hash).to include({
                                         supplement: [{
                                           content: 'ＲＰ１服用後',
                                           author: 1
                                         },{
                                           content: '一包化',
                                           author: 1
                                         }]
                                       })
      end
    end
  end

  describe JahisParser::Row::DosageAdministration::Supplement do
    let(:row) { JahisParser::Row::DosageAdministration::Supplement.new(csv.split(/,/)) }
    describe '#new' do
      let(:csv) { '311,1,ＲＰ１服用後,1' }
      context '正常なデータ' do
        it '正常に取り込めること' do
          expect(row.to_hash).to include({
                                           content: 'ＲＰ１服用後',
                                           author: 1
                                         })
        end
      end
    end
  end
end

RSpec.describe JahisParser::Row::RecipeDoseCaution do
  describe '#new' do
    let(:csv) { '391,1,車の運転は控えてください。,1' }
    let(:row) { JahisParser::Row::RecipeDoseCaution.new(csv.split(/,/)) }
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         content: '車の運転は控えてください。',
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::DoseCaution do
  describe '#new' do
    let(:csv) { '401,他の薬を併用する際は、相談してください。,1' }
    let(:row) { JahisParser::Row::DoseCaution.new(csv.split(/,/)) }
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         content: '他の薬を併用する際は、相談してください。',
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::MedicalFacilityProviding do
  describe '#new' do
    let(:csv) { '411,嚥下困難が見られるため、錠剤は粉砕して投与する。,31,1' }
    let(:row) { JahisParser::Row::MedicalFacilityProviding.new(csv.split(/,/)) }
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         content: '嚥下困難が見られるため、錠剤は粉砕して投与する。',
                                         providing_type: 31,
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::LeftoverMedicineConfirmation do
  describe '#new' do
    let(:csv) { '421,ロキソプロフェンが 10 錠残薬。症状改善による自己判断で服用中断。,1' }
    let(:row) { JahisParser::Row::LeftoverMedicineConfirmation.new(csv.split(/,/)) }
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         content: 'ロキソプロフェンが 10 錠残薬。症状改善による自己判断で服用中断。',
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::Note do
  describe '#new' do
    let(:csv) { '501,正しい飲み方は薬袋等をご覧下さい。,1' }
    let(:row) { JahisParser::Row::Note.new(csv.split(/,/)) }
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         content: '正しい飲み方は薬袋等をご覧下さい。',
                                         author: 1
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::PatientEntry do
  describe '#new' do
    let(:csv) { '601,飲み始めてから、昼に眠くなるようになった。,H280411' }
    let(:row) { JahisParser::Row::PatientEntry.new(csv.split(/,/)) }
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         content: '飲み始めてから、昼に眠くなるようになった。',
                                         entried_on: '20160411'
                                       })
      end
    end
  end
end

RSpec.describe JahisParser::Row::Pharmacist do
  describe '#new' do
    let(:csv) { '701,工業会 次郎,工業会薬局 駅前店,03-3506-8010,H280411,,1' }
    let(:row) { JahisParser::Row::Pharmacist.new(csv.split(/,/)) }
    context '正常なデータ' do
      it '正常に取り込めること' do
        expect(row.to_hash).to include({
                                         name: '工業会 次郎',
                                         pharmacy: '工業会薬局 駅前店',
                                         contact: '03-3506-8010',
                                         started_on: '20160411',
                                         ended_on: nil,
                                         author: 1
                                       })
      end
    end
  end
end