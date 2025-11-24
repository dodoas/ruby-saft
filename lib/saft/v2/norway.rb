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

  class GroupingCategory < Dry::Struct
    attribute :grouping_category, Types::String
    attribute :category_description_no, Types::String
    attribute :category_description_en, Types::String
    attribute :grouping_code, Types::String
    attribute :code_description_no, Types::String
    attribute :code_description_en, Types::String
  end

  GroupingCategories = Types::Array.of(GroupingCategory)

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

  def self.grouping_categories
    return @grouping_categories if defined?(@grouping_categories)

    @grouping_categories = {}
    general_ledger_grouping_categories
      .each { @grouping_categories[_1.grouping_code] = _1 }

    @grouping_categories
  end

  def self.grouping_category(grouping_code)
    grouping_categories[grouping_code]
  end

  def self.grouping_category!(grouping_code)
    grouping_categories.fetch(grouping_code)
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

  def self.general_ledger_grouping_categories
    return @general_ledger_grouping_categories if defined?(@general_ledger_grouping_categories)

    @general_ledger_grouping_categories = parse_general_ledger_grouping_catergories(
      SAFT::V2::Norway::PATH + "general_ledger_account_grouping_category_codes_income_statement_naeringsspesifikasjon.csv",
    )
  end

  def self.parse_general_ledger_grouping_catergories(path)
    groupings = []
    CSV.foreach(path, headers: true, col_sep: ";") do |row|

      groupings.push({
        grouping_category: row["GroupingCategory"],
        category_description_no: row["CategoryDescriptionNOB"],
        category_description_en: row["CategoryDescriptionENG"],
        grouping_code: row["GroupingCode"],
        code_description_no: row["CodeDescriptionNOB"],
        code_description_en: row["CodeDescriptionENG"],
      })
    end

    GroupingCategories[groupings].freeze
  end
end
