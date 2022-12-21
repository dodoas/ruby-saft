# frozen_string_literal: true

require "csv"

module SAFT::V2::Norway
  PATH = SAFT.gem_root + "vendor" + "norway"

  module Types
    include Dry.Types

    Date = Params::Date
    DateTime = Params::DateTime
    Integer = Coercible::Integer
    Decimal = Coercible::Decimal
    Bool = Params::Bool
    String = Strict::String

    VatRates = Types::String.enum(
      "Regular rate",
      "Reduced rate, low",
      "Reduced rate, middle",
      "Reduced rate, foodstuffs",
      "Reduced rate, raw fish",
      "Reduced rate",
      "Zero rate",
    )
  end

  class VatTaxCode < Dry::Struct
    attribute :code, Types::String
    attribute :description_no, Types::String
    attribute :description_en, Types::String
    attribute :tax_rate, Types::VatRates.optional.meta(omittable: true)
    attribute :compensation, Types::Bool.optional.meta(omittable: true)
  end

  VatTaxCodes = Types::Array.of(VatTaxCode)

  class Account < Dry::Struct
    attribute :number, Types::String
    attribute :description_no, Types::String
    attribute :description_en, Types::String
  end

  Accounts = Types::Array.of(Account)

  def self.vat_codes
    return @vat_codes if defined?(@vat_codes)

    vat_codes = []
    CSV.foreach(
      SAFT::V2::Norway::PATH + "standard_tax_codes.csv",
      headers: true,
      col_sep: ";",
    ) do |row|
      vat_codes.push({
        code: row["Code"],
        description_no: row["DescriptionNOB"],
        description_en: row["DescriptionENG"],
        tax_rate: row["TaxRate"],
        compensation: row["Compensation"],
      })
    end

    @vat_codes = VatTaxCodes[vat_codes].freeze
  end

  def self.std_account_map
    return @std_account_map if defined?(@std_account_map)

    @std_account_map = {}
    general_ledger_accounts_2_digits
      .each { @std_account_map[_1.number] = _1 }
    general_ledger_accounts_4_digits
      .each { @std_account_map[_1.number] = _1 }

    @std_account_map
  end

  def self.std_account(number)
    std_account_map[number]
  end

  def self.std_account!(number)
    std_account_map.fetch(number)
  end

  def self.vat_code_map
    return @vat_code_map if defined?(@vat_code_map)

    @vat_code_map = vat_codes.each_with_object({}) do |vat_code, object|
      object[vat_code.code] = vat_code
    end
  end

  def self.vat_code(code)
    vat_code_map[code]
  end

  def self.vat_code!(code)
    vat_code_map.fetch(code)
  end

  def self.general_ledger_accounts_2_digits
    return @general_ledger_accounts_2_digits if defined?(@general_ledger_accounts_2_digits)

    @general_ledger_accounts_2_digits = parse_general_ledger_accounts(
      SAFT::V2::Norway::PATH + "general_ledger_standard_accounts_2_character.csv",
    )
  end

  def self.general_ledger_accounts_4_digits
    return @general_ledger_accounts_4_digits if defined?(@general_ledger_accounts_4_digits)

    @general_ledger_accounts_4_digits = parse_general_ledger_accounts(
      SAFT::V2::Norway::PATH + "general_ledger_standard_accounts_4_character.csv",
    )
  end

  def self.parse_general_ledger_accounts(path)
    accounts = []

    CSV.foreach(path, headers: true, col_sep: ";") do |row|
      accounts.push({
        number: row["AccountID"],
        description_no: row["DescriptionNOB"],
        description_en: row["DescriptionENG"],
      })
    end

    Accounts[accounts].freeze
  end
end
