# frozen_string_literal: true

require "dry-struct"

# This file contains the xml intermediate structure
# The node names are generated from the XSD located in
# ./vendor/SAF-T_Financial_Schema1.10.xsd. There are at least a couple of nodes
# which are ignored since  it has the comment "Not in use.". I don't look at it as
# a bug since we don't need then but we can implement when/if thay are ever
# needed.

module SAFT::V2::Types
  module Types
    include Dry.Types

    Date = Params::Date
    DateTime = Params::DateTime
    Integer = Coercible::Integer
    Decimal = Coercible::Decimal
    Bool = Params::Bool
    String = Strict::String
    PositiveInteger = Types::Integer.constrained(gteq: 0)
  end

  # not Ideal as we are extending the global scope
  Dry::Logic::Predicates.predicate(:digits?) do |num, input|
    _sign, significant_digits, _base, exponent = input.split
    n_significant_digits = significant_digits.length
    n_significant_digits += -exponent if exponent.negative?
    n_significant_digits <= num
  end

  Dry::Logic::Predicates.predicate(:fraction_digitst?) do |num, input|
    digits?(num, input.frac)
  end

  # Aka base
  module ObjectStrutures
    def self.extended(base)
      base.class_eval do
        # not how I wanted to write this but this is how it turn out then I
        # wanted to have different level of strictness for types like
        # SAFmiddle1textType

        klass = Class.new(Dry::Struct) do
          attribute(:amount, base::SAFmonetaryType)

          attribute(:currency_code, base::ISOCurrencyCode.optional.meta(omittable: true))
          attribute(:currency_amount, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:exchange_rate, base::SAFexchangerateType.optional.meta(omittable: true))
        end

        base.const_set(:AmountStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:analysis_type, base::SAFcodeType)
          attribute(:analysis_id, base::SAFlongtextType)
          attribute(:analysis_amount, base::AmountStructure.optional.meta(omittable: true))
        end

        base.const_set(:AnalysisStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:analysis_type, base::SAFcodeType)
          attribute(:analysis_id, base::SAFlongtextType)
        end

        base.const_set(:AnalysisPartyInfoStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:tax_type, base::SAFcodeType.optional.meta(omittable: true))
          attribute(:tax_code, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:tax_percentage, Types::Decimal.optional.meta(omittable: true))
          attribute(:country, base::ISOCountryCode.optional.meta(omittable: true))
          attribute(:tax_base, Types::Decimal.optional.meta(omittable: true))
          attribute(:tax_base_description, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:tax_amount, base::AmountStructure)
          attribute(:tax_exemption_reason, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:tax_declaration_period, base::SAFmiddle1textType.optional.meta(omittable: true))
        end

        base.const_set(:TaxInformationStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:tax_registration_number, base::SAFmiddle1textType)
          # ignored since xsd states "Not in use."
          # attribute :tax_type, base::SAFcodeType.optional.meta(omittable: true)
          # attribute :tax_number, base::SAFmiddle1textType.optional.meta(omittable: true)
          attribute(:tax_authority, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:tax_verification_date, Types::Date.optional.meta(omittable: true))
        end

        base.const_set(:TaxIDStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:tax_reporting_jurisdiction, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:company_entity, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:selection_start_date, Types::Date.optional.meta(omittable: true))
          attribute(:selection_end_date, Types::Date.optional.meta(omittable: true))
          attribute(:period_start, Types::PositiveInteger.optional.meta(omittable: true))
          attribute(:period_start_year, Types::Integer.constrained(gteq: 1970).constrained(lteq: 2100).optional.meta(omittable: true))
          attribute(:period_end, Types::PositiveInteger.optional.meta(omittable: true))
          attribute(:period_end_year, Types::Integer.constrained(gteq: 1970).constrained(lteq: 2100).optional.meta(omittable: true))
          attribute(:document_type, base::SAFlongtextType.optional.meta(omittable: true))
          attribute(:other_criterias, Types::Array.of(base::SAFlongtextType).optional.meta(omittable: true))
        end

        base.const_set(:SelectionCriteriaStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:title, base::SAFcodeType.optional.meta(omittable: true))
          attribute(:first_name, base::SAFmiddle1textType)
          attribute(:initials, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:last_name_prefix, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:last_name, base::SAFmiddle2textType)
          attribute(:birth_name, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:salutation, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:other_titles, Types::Array.of(base::SAFshorttextType).optional.meta(omittable: true))
        end

        base.const_set(:PersonNameStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:days, Types::PositiveInteger.optional.meta(omittable: true))
          attribute(:months, Types::PositiveInteger.optional.meta(omittable: true))
          attribute(:cash_discount_days, Types::PositiveInteger.optional.meta(omittable: true))
          attribute(:cash_discount_rate, Types::Decimal.constrained(gteq: 0).constrained(lteq: 100).optional.meta(omittable: true))
          attribute(:free_billing_month, Types::Bool.optional.meta(omittable: true))
        end

        base.const_set(:PaymentTerms, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:payment_terms, base::PaymentTerms.optional.meta(omittable: true))
          attribute(:nace_code, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:currency_code, base::ISOCurrencyCode.optional.meta(omittable: true))
          attribute(:type, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:status, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:analyses, Types::Array.of(base::AnalysisPartyInfoStructure).optional.meta(omittable: true))
          attribute(:notes, Types::String.optional.meta(omittable: true))
        end

        base.const_set(:PartyInfoStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:street_name, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:number, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:additional_address_detail, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:building, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:city, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:postal_code, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:region, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:country, base::ISOCountryCode.optional.meta(omittable: true))
          attribute(:address_type, base::AddressType.optional.meta(omittable: true))
        end

        base.const_set(:AddressStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:delivery_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:delivery_date, Types::Date.optional.meta(omittable: true))
          attribute(:warehouse_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:location_id, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:ucr, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:address, base::AddressStructure.optional.meta(omittable: true))
        end

        base.const_set(:ShippingPointStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:contact_person, base::PersonNameStructure)
          attribute(:telephone, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:fax, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:email, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:website, Types::String.optional.meta(omittable: true))
          attribute(:mobile_phone, base::SAFshorttextType.optional.meta(omittable: true))
        end

        base.const_set(:ContactInformationStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:iban_number, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:bank_account_number, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:bank_account_name, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:sort_code, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:bic, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:currency_code, base::ISOCurrencyCode.optional.meta(omittable: true))
          attribute(:general_ledger_account_id, base::SAFmiddle2textType.optional.meta(omittable: true))
        end

        base.const_set(:BankAccountStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:registration_number, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:name, base::SAFmiddle2textType)
          attribute(:addresses, Types::Array.of(base::AddressStructure))
          attribute(:contacts, Types::Array.of(base::ContactInformationStructure).optional.meta(omittable: true))
          attribute(:tax_registrations, Types::Array.of(base::TaxIDStructure).optional.meta(omittable: true))
          attribute(:bank_accounts, Types::Array.of(base::BankAccountStructure).optional.meta(omittable: true))
        end

        base.const_set(:CompanyStructure, klass)

        klass = Class.new(base::CompanyStructure) do
          attribute(:registration_number, base::SAFmiddle1textType)
          attribute(:name, base::SAFmiddle2textType)
          attribute(:addresses, Types::Array.of(base::AddressStructure))
          attribute(:contacts, Types::Array.of(base::ContactInformationStructure))
          attribute(:tax_registrations, Types::Array.of(base::TaxIDStructure).optional.meta(omittable: true))
          attribute(:bank_accounts, Types::Array.of(base::BankAccountStructure).optional.meta(omittable: true))
        end

        base.const_set(:CompanyHeaderStructure, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:audit_file_version, base::SAFcodeType)
          attribute(:audit_file_country, base::ISOCountryCode)
          # ignored sine XSD said "not in use."
          # attribute :audit_file_region, base::SAFcodeType.optional.meta(omittable: true)
          attribute(:audit_file_date_created, Types::Date)
          attribute(:software_company_name, base::SAFmiddle2textType)
          attribute(:software_id, base::SAFlongtextType)
          attribute(:software_version, base::SAFshorttextType)
          attribute(:company, base::CompanyHeaderStructure)
          attribute(:default_currency_code, base::ISOCurrencyCode)
          attribute(:selection_criteria, base::SelectionCriteriaStructure.optional.meta(omittable: true))
          attribute(:header_comment, base::SAFlongtextType.optional.meta(omittable: true))
        end

        base.const_set(:HeaderStructure, klass)

        klass = Class.new(base::HeaderStructure) do
          attribute(:tax_accounting_basis, base::SAFshorttextType)
          attribute(:tax_entity, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:user_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:audit_file_sender, base::CompanyStructure.optional.meta(omittable: true))
        end

        base.const_set(:Header, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:account_id, base::SAFmiddle2textType)
          attribute(:account_description, base::SAFlongtextType)
          attribute(:standard_account_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:grouping_category, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:grouping_code, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:account_type, base::SAFshorttextType)
          attribute(:account_creation_date, Types::Date.optional.meta(omittable: true))
          attribute(:opening_debit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:opening_credit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:closing_debit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:closing_credit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
        end

        base.const_set(:Account, klass)

        klass = Class.new(base::CompanyStructure) do
          attribute(:customer_id, base::SAFmiddle1textType)
          attribute(:self_billing_indicator, base::SAFcodeType.optional.meta(omittable: true))
          attribute(:account_id, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:opening_debit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:opening_credit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:closing_debit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:closing_credit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:party_info, base::PartyInfoStructure.optional.meta(omittable: true))
        end

        base.const_set(:Customer, klass)

        klass = Class.new(base::CompanyStructure) do
          attribute(:supplier_id, base::SAFmiddle1textType)
          attribute(:self_billing_indicator, base::SAFcodeType.optional.meta(omittable: true))
          attribute(:account_id, base::SAFmiddle2textType.optional.meta(omittable: true))
          attribute(:opening_debit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:opening_credit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:closing_debit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:closing_credit_balance, base::SAFmonetaryType.optional.meta(omittable: true))
          attribute(:party_info, base::PartyInfoStructure.optional.meta(omittable: true))
        end

        base.const_set(:Supplier, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:tax_code, base::SAFmiddle1textType)
          attribute(:effective_date, Types::Date.optional.meta(omittable: true))
          attribute(:expiration_date, Types::Date.optional.meta(omittable: true))
          attribute(:description, base::SAFlongtextType.optional.meta(omittable: true))
          attribute(:tax_percentage, Types::Decimal.optional.meta(omittable: true))
          # ignored because XSD states "Not in Use."
          # attribute :flat_tax_rate, AmountStructure.optional.meta(omittable: true)
          attribute(:country, base::ISOCountryCode)
          # ignored because XSD states "Not in Use."
          # attribute :region, base::SAFcodeType.optional.meta(omittable: true)
          attribute(:standard_tax_code, base::SAFmiddle1textType)
          attribute(:compensation, Types::Bool.optional.meta(omittable: true))
          attribute(:base_rates, Types::Array.of(Types::Decimal))
        end

        base.const_set(:TaxCodeDetails, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:tax_type, base::SAFcodeType)
          attribute(:description, base::SAFlongtextType)
          attribute(:tax_code_details, Types::Array.of(base::TaxCodeDetails).constrained(min_size: 1))
        end

        base.const_set(:TaxTableEntry, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:analysis_type, base::SAFcodeType)
          attribute(:analysis_type_description, base::SAFlongtextType)
          attribute(:analysis_id, base::SAFmiddle1textType)
          attribute(:analysis_id_description, base::SAFlongtextType)
          attribute(:start_date, Types::Date.optional.meta(omittable: true))
          attribute(:end_date, Types::Date.optional.meta(omittable: true))
          attribute(:status, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:analyses, Types::Array.of(base::AnalysisPartyInfoStructure).optional.meta(omittable: true))
        end

        base.const_set(:AnalysisTypeTableEntry, klass)

        klass = Class.new(base::CompanyStructure) do
          attribute(:owner_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:account_id, base::SAFmiddle2textType.optional.meta(omittable: true))
        end

        base.const_set(:Owner, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:general_ledger_accounts, Types::Array.of(base::Account).optional.meta(omittable: true))
          # ignored since xsd said "Not in use."
          # attribute :taxonomies, Taxonomies
          attribute(:customers, Types::Array.of(base::Customer).optional.meta(omittable: true))
          attribute(:suppliers, Types::Array.of(base::Supplier).optional.meta(omittable: true))
          attribute(:tax_table, Types::Array.of(base::TaxTableEntry).optional.meta(omittable: true))
          # ignored since xsd said "Not in use."
          # attribute :uom_table, UOMTable
          attribute(:analysis_type_table, Types::Array.of(base::AnalysisTypeTableEntry).optional.meta(omittable: true))
          # ignored since xsd said "Not in use."
          # attribute :movement_type_table, MovementTypeTable
          # ignored since xsd said "Not in use."
          # attribute :products, Products
          # ignored since xsd said "Not in use."
          # attribute :physical_stock, PhysicalStock
          attribute(:owners, Types::Array.of(base::Owner).optional.meta(omittable: true))
          # ignored since xsd said "Not in use."
          # attribute :assets, Assets
        end

        base.const_set(:MasterFiles, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:record_id, base::SAFshorttextType)
          attribute(:account_id, base::SAFmiddle2textType)
          attribute(:analyses, Types::Array.of(base::AnalysisStructure).optional.meta(omittable: true))
          attribute(:value_date, Types::Date.optional.meta(omittable: true))
          attribute(:source_document_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:customer_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:supplier_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:description, base::SAFlongtextType)
          attribute(:debit_amount, base::AmountStructure.optional.meta(omittable: true))
          attribute(:credit_amount, base::AmountStructure.optional.meta(omittable: true))
          attribute(:tax_information, Types::Array.of(base::TaxInformationStructure).optional.meta(omittable: true))
          attribute(:reference_number, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:cid, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:due_date, Types::Date.optional.meta(omittable: true))
          attribute(:quantity, base::SAFquantityType.optional.meta(omittable: true))
          attribute(:cross_reference, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:system_entry_time, Types::DateTime.optional.meta(omittable: true))
          attribute(:owner_id, base::SAFmiddle1textType.optional.meta(omittable: true))
        end

        base.const_set(:Line, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:transaction_id, base::SAFmiddle2textType)
          attribute(:period, Types::Integer)
          attribute(:period_year, Types::Integer)
          attribute(:transaction_date, Types::Date)
          attribute(:source_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:transaction_type, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:description, base::SAFlongtextType)
          attribute(:batch_id, base::SAFmiddle1textType.optional.meta(omittable: true))
          attribute(:system_entry_date, Types::Date)
          attribute(:gl_posting_date, Types::Date)
          # ignored since xsd said "Not in use."
          # attribute :CustomerID, base::SAFmiddle1textType.optional.meta(omittable: true)
          # ignored since xsd said "Not in use."
          # attribute :SupplierID, base::SAFmiddle1textType.optional.meta(omittable: true)
          attribute(:system_id, base::SAFshorttextType.optional.meta(omittable: true))
          attribute(:lines, Types::Array.of(base::Line))
        end

        base.const_set(:Transaction, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:journal_id, base::SAFshorttextType)
          attribute(:description, base::SAFlongtextType)
          attribute(:type, base::SAFcodeType)
          attribute(:transactions, Types::Array.of(base::Transaction).optional.meta(omittable: true))
        end

        base.const_set(:Journal, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:number_of_entries, Types::Integer)
          attribute(:total_debit, base::SAFmonetaryType)
          attribute(:total_credit, base::SAFmonetaryType)
          attribute(:journals, Types::Array.of(base::Journal).optional.meta(omittable: true))
        end

        base.const_set(:GeneralLedgerEntries, klass)

        klass = Class.new(Dry::Struct) do
          attribute(:header, base::Header)
          attribute(:master_files, base::MasterFiles.optional.meta(omittable: true))
          attribute(:general_ledger_entries, base::GeneralLedgerEntries.optional.meta(omittable: true))
          # ignored since xsd said "Not in use."
          # attribute :source_documents, base::SourceDocuments
        end

        base.const_set(:AuditFile, klass)
      end
    end
  end

  module Relaxed
    ISOCurrencyCode = Types::String
    ISOCountryCode = Types::String
    SAFcodeType = Types::String
    SAFshorttextType = Types::String
    SAFmiddle1textType = Types::String
    SAFmiddle2textType = Types::String
    SAFlongtextType = Types::String
    SAFmonetaryType = Types::Decimal
    SAFexchangerateType = Types::Decimal
    SAFquantityType = Types::Decimal
    SAFweightType = Types::Decimal
    AddressType = Types::String

    extend ObjectStrutures
  end

  module Strict
    ISOCurrencyCode = Types::String.constrained(size: 3)
    ISOCountryCode = Types::String.constrained(size: 2)
    SAFcodeType = Types::String.constrained(max_size: 9)
    SAFshorttextType = Types::String.constrained(max_size: 18)
    SAFmiddle1textType = Types::String.constrained(max_size: 35)
    SAFmiddle2textType = Types::String.constrained(max_size: 70)
    SAFlongtextType = Types::String.constrained(max_size: 256)
    SAFmonetaryType = Types::Decimal.constrained(digits: 18, fraction_digitst: 2)
    SAFexchangerateType = Types::Decimal.constrained(digits: 18, fraction_digitst: 8)
    SAFquantityType = Types::Decimal.constrained(digits: 22, fraction_digitst: 6)
    SAFweightType = Types::Decimal.constrained(digits: 14, fraction_digitst: 3)
    AddressType = Types::String.enum("StreetAddress", "PostalAddress", "BillingAddress", "ShipToAddress", "ShipFromAddress")

    extend ObjectStrutures
  end

  module Sliced
    def self.slice_string(length)
      proc do |value|
        if value.is_a?(::String)
          value.slice(0, length)
        else
          value
        end
      end
    end

    ISOCurrencyCode = Types.Constructor(Strict::ISOCurrencyCode, &slice_string(3))
    ISOCountryCode = Types.Constructor(Strict::ISOCountryCode, &slice_string(2))
    SAFcodeType = Types.Constructor(Strict::SAFcodeType, &slice_string(9))
    SAFshorttextType = Types.Constructor(Strict::SAFshorttextType, &slice_string(18))
    SAFmiddle1textType = Types.Constructor(Strict::SAFmiddle1textType, &slice_string(35))
    SAFmiddle2textType = Types.Constructor(Strict::SAFmiddle2textType, &slice_string(70))
    SAFlongtextType = Types.Constructor(Strict::SAFlongtextType, &slice_string(256))
    SAFmonetaryType = Types::Decimal.constrained(digits: 18, fraction_digitst: 2)
    SAFexchangerateType = Types::Decimal.constrained(digits: 18, fraction_digitst: 8)
    SAFquantityType = Types::Decimal.constrained(digits: 22, fraction_digitst: 6)
    SAFweightType = Types::Decimal.constrained(digits: 14, fraction_digitst: 3)

    AddressType = Types::String.enum("StreetAddress", "PostalAddress", "BillingAddress", "ShipToAddress", "ShipFromAddress")

    extend ObjectStrutures
  end

  # Want to keep developer experience where you can call
  # SAFT::V2::Types::AuditFile and get a Audit file. We have three different
  # AuditFile. We have Strict/Relaxed/Sliced.
  include Strict
end
