# frozen_string_literal: true

require 'json'
require_relative 'jahis_parser/record'

# JAHIS
module JahisParser
  # Loader
  class Loader
    require 'csv'

    def initialize(filename)
      @filename = filename
    end

    def exec
      rows = CSV.read(@filename, encoding: 'CP932:UTF-8')

      unknown = []

      record = Record.new(rows.shift)

      rows.each do |row|
        number = row.shift.to_i

        record.state number

        case number
        when 1
          # (1) 患者情報レコード
          record.patient_info row
        when 2
          # (2) 患者特記レコード
          record.patient_note row
        when 3
          # (3) 一般用医薬品服用レコード
          record.otc_drug row
        when 4
          # (4) 手帳メモレコード
          record.memo row
        when 5
          # (5) 調剤等年月日レコード
          # このレコードが出現したら新たな調剤情報を作成する
          record.dispensing_info row
        when 11
          # (11) 調剤－医療機関等レコード
          record.dispensing_info.last.dispensing_facility row
        when 15
          # (15) 調剤－医師・薬剤師レコード
          record.dispensing_info.last.dispensing_doctor_pharmacist row
        when 51
          # (51) 処方－医療機関レコード
          record.dispensing_info.last.prescription_facility row
        when 55
          # (55) 処方－医師レコード
          # 内部的にはprescriptionの新規レコードが作成される
          # 呼ばない場合は prescription は暗黙的に1つのみ作成される
          record.dispensing_info.last.doctor row
        when 201
          # (201) 薬品レコード
          # 300~399 のレコードが出現していない場合、

        when 701
          # (701) かかりつけ薬剤師レコード
          record.pharmacist row
        else
          unknown.push [number, row]
        end
      end

      pp record
      pp unknown
    end
  end
end
