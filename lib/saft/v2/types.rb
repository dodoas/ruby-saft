# frozen_string_literal: true

require "dry-struct"

# This file containt the xml intermidiate structure
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
  end

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

  class AmountStructure < Dry::Struct
    attribute :amount, SAFmonetaryType

    attribute :currency_code, ISOCurrencyCode.optional.meta(omittable: true)
    attribute :currency_amount, SAFmonetaryType.optional.meta(omittable: true)
    attribute :exchange_rate, SAFexchangerateType.optional.meta(omittable: true)
  end

  class AnalysisStructure < Dry::Struct
    attribute :analysis_type, SAFcodeType
    attribute :analysis_id, SAFlongtextType
    attribute :analysis_amount, AmountStructure.optional.meta(omittable: true)
  end

  class AnalysisPartyInfoStructure < Dry::Struct
    attribute :analysis_type, SAFcodeType
    attribute :analysis_id, SAFlongtextType
  end

  class TaxInformationStructure < Dry::Struct
    attribute :tax_type, SAFcodeType.optional.meta(omittable: true)
    attribute :tax_code, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :tax_percentage, Types::Decimal.optional.meta(omittable: true)
    attribute :country, ISOCountryCode.optional.meta(omittable: true)
    attribute :tax_base, Types::Decimal.optional.meta(omittable: true)
    attribute :tax_base_description, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :tax_amount, AmountStructure
    attribute :tax_exemption_reason, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :tax_declaration_period, SAFmiddle1textType.optional.meta(omittable: true)
  end

  class TaxIDStructure < Dry::Struct
    attribute :tax_registration_number, SAFmiddle1textType
    # ignored since xsd states "Not in use."
    # attribute :tax_type, SAFcodeType.optional.meta(omittable: true)
    # attribute :tax_number, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :tax_authority, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :tax_verification_date, Types::Date.optional.meta(omittable: true)
  end

  class SelectionCriteriaStructure < Dry::Struct
    attribute :tax_reporting_jurisdiction, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :company_entity, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :selection_start_date, Types::Date.optional.meta(omittable: true)
    attribute :selection_end_date, Types::Date.optional.meta(omittable: true)
    attribute :period_start, Types::Integer.optional.meta(omittable: true)
    attribute :period_start_year, Types::Integer.optional.meta(omittable: true)
    attribute :period_end, Types::Integer.optional.meta(omittable: true)
    attribute :period_end_year, Types::Integer.optional.meta(omittable: true)
    attribute :document_type, SAFlongtextType.optional.meta(omittable: true)
    attribute :other_criterias, Types::Array.of(SAFlongtextType).optional.meta(omittable: true)
  end

  class PersonNameStructure < Dry::Struct
    attribute :title, SAFcodeType.optional.meta(omittable: true)
    attribute :first_name, SAFmiddle1textType
    attribute :initials, SAFshorttextType.optional.meta(omittable: true)
    attribute :last_name_prefix, SAFshorttextType.optional.meta(omittable: true)
    attribute :last_name, SAFmiddle2textType
    attribute :birth_name, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :salutation, SAFshorttextType.optional.meta(omittable: true)
    attribute :other_titles, Types::Array.of(SAFshorttextType).optional.meta(omittable: true)
  end

  class PaymentTerms < Dry::Struct
    attribute :days, Types::Integer.optional.meta(omittable: true)
    attribute :months, Types::Integer.optional.meta(omittable: true)
    attribute :cash_discount_days, Types::Integer.optional.meta(omittable: true)
    attribute :cash_discount_rate, Types::Decimal.optional.meta(omittable: true)
    attribute :free_billing_month, Types::Bool.optional.meta(omittable: true)
  end

  class PartyInfoStructure < Dry::Struct
    attribute :payment_terms, PaymentTerms.optional.meta(omittable: true)
    attribute :nace_code, SAFshorttextType.optional.meta(omittable: true)
    attribute :currency_code, ISOCurrencyCode.optional.meta(omittable: true)
    attribute :type, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :status, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :analyses, Types::Array.of(AnalysisPartyInfoStructure).optional.meta(omittable: true)
    attribute :notes, Types::String.optional.meta(omittable: true)
  end

  class AddressStructure < Dry::Struct
    attribute :street_name, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :number, SAFshorttextType.optional.meta(omittable: true)
    attribute :additional_address_detail, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :building, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :city, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :postal_code, SAFshorttextType.optional.meta(omittable: true)
    attribute :region, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :country, ISOCountryCode.optional.meta(omittable: true)
    attribute :address_type, Types::String.optional.meta(omittable: true)
  end

  class ShippingPointStructure < Dry::Struct
    attribute :delivery_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :delivery_date, Types::Date.optional.meta(omittable: true)
    attribute :warehouse_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :location_id, SAFshorttextType.optional.meta(omittable: true)
    attribute :ucr, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :address, AddressStructure.optional.meta(omittable: true)
  end

  class ContactInformationStructure < Dry::Struct
    attribute :contact_person, PersonNameStructure
    attribute :telephone, SAFshorttextType.optional.meta(omittable: true)
    attribute :fax, SAFshorttextType.optional.meta(omittable: true)
    attribute :email, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :website, Types::String.optional.meta(omittable: true)
    attribute :mobile_phone, SAFshorttextType.optional.meta(omittable: true)
  end

  class ContactHeaderStructure < ContactInformationStructure
    attribute :telephone, SAFshorttextType
  end

  class BankAccountStructure < Dry::Struct
    attribute :iban_number, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :bank_account_number, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :bank_account_name, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :sort_code, SAFshorttextType.optional.meta(omittable: true)
    attribute :bic, SAFshorttextType.optional.meta(omittable: true)
    attribute :currency_code, ISOCurrencyCode.optional.meta(omittable: true)
    attribute :general_ledger_account_id, SAFmiddle2textType.optional.meta(omittable: true)
  end

  class CompanyStructure < Dry::Struct
    attribute :registration_number, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :name, SAFmiddle2textType
    attribute :addresses, Types::Array.of(AddressStructure)
    attribute :contacts, Types::Array.of(ContactInformationStructure).optional.meta(omittable: true)
    attribute :tax_registrations, Types::Array.of(TaxIDStructure).optional.meta(omittable: true)
    attribute :bank_accounts, Types::Array.of(BankAccountStructure).optional.meta(omittable: true)
  end

  class CompanyHeaderStructure < CompanyStructure
    attribute :registration_number, SAFmiddle1textType
    attribute :name, SAFmiddle2textType
    attribute :addresses, Types::Array.of(AddressStructure)
    attribute :contacts, Types::Array.of(ContactInformationStructure)
    attribute :tax_registrations, Types::Array.of(TaxIDStructure).optional.meta(omittable: true)
    attribute :bank_accounts, Types::Array.of(BankAccountStructure).optional.meta(omittable: true)
  end

  class HeaderStructure < Dry::Struct
    attribute :audit_file_version, SAFcodeType
    attribute :audit_file_country, ISOCountryCode
    # ignored sine XSD said "not in use."
    # attribute :audit_file_region, SAFcodeType.optional.meta(omittable: true)
    attribute :audit_file_date_created, Types::Date
    attribute :software_company_name, SAFmiddle2textType
    attribute :software_id, SAFlongtextType
    attribute :software_version, SAFshorttextType
    attribute :company, CompanyHeaderStructure
    attribute :default_currency_code, ISOCurrencyCode
    attribute :selection_criteria, SelectionCriteriaStructure.optional.meta(omittable: true)
    attribute :header_comment, SAFlongtextType.optional.meta(omittable: true)
  end

  class Header < HeaderStructure
    attribute :tax_accounting_basis, SAFshorttextType
    attribute :tax_entity, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :user_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :audit_file_sender, CompanyStructure.optional.meta(omittable: true)
  end

  class Account < Dry::Struct
    attribute :account_id, SAFmiddle2textType
    attribute :account_description, SAFlongtextType
    attribute :standard_account_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :grouping_category, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :grouping_code, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :account_type, SAFshorttextType
    attribute :account_creation_date, Types::Date.optional.meta(omittable: true)
    attribute :opening_debit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :opening_credit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :closing_debit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :closing_credit_balance, SAFmonetaryType.optional.meta(omittable: true)
  end

  class Customer < CompanyStructure
    attribute :customer_id, SAFmiddle1textType
    attribute :self_billing_indicator, SAFcodeType.optional.meta(omittable: true)
    attribute :account_id, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :opening_debit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :opening_credit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :closing_debit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :closing_credit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :party_info, PartyInfoStructure.optional.meta(omittable: true)
  end

  class Supplier < CompanyStructure
    attribute :supplier_id, SAFmiddle1textType
    attribute :self_billing_indicator, SAFcodeType.optional.meta(omittable: true)
    attribute :account_id, SAFmiddle2textType.optional.meta(omittable: true)
    attribute :opening_debit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :opening_credit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :closing_debit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :closing_credit_balance, SAFmonetaryType.optional.meta(omittable: true)
    attribute :party_info, PartyInfoStructure.optional.meta(omittable: true)
  end

  class TaxCodeDetails < Dry::Struct
    attribute :tax_code, SAFmiddle1textType
    attribute :effective_date, Types::Date.optional.meta(omittable: true)
    attribute :expiration_date, Types::Date.optional.meta(omittable: true)
    attribute :description, SAFlongtextType.optional.meta(omittable: true)
    attribute :tax_percentage, Types::Decimal.optional.meta(omittable: true)
    # ignored because XSD states "Not in Use."
    # attribute :flat_tax_rate, AmountStructure.optional.meta(omittable: true)
    attribute :country, ISOCountryCode
    # ignored because XSD states "Not in Use."
    # attribute :region, SAFcodeType.optional.meta(omittable: true)
    attribute :standard_tax_code, SAFmiddle1textType
    attribute :compensation, Types::Bool.optional.meta(omittable: true)
    attribute :base_rates, Types::Array.of(Types::Decimal)
  end

  class TaxTableEntry < Dry::Struct
    attribute :tax_type, SAFcodeType
    attribute :description, SAFlongtextType
    attribute :tax_code_details, Types::Array.of(TaxCodeDetails)
  end

  class AnalysisTypeTableEntry < Dry::Struct
    attribute :analysis_type, SAFcodeType
    attribute :analysis_type_description, SAFlongtextType
    attribute :analysis_id, SAFmiddle1textType
    attribute :analysis_id_description, SAFlongtextType
    attribute :start_date, Types::Date.optional.meta(omittable: true)
    attribute :end_date, Types::Date.optional.meta(omittable: true)
    attribute :status, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :analyses, Types::Array.of(AnalysisPartyInfoStructure).optional.meta(omittable: true)
  end

  class Owner < CompanyStructure
    attribute :owner_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :account_id, SAFmiddle2textType.optional.meta(omittable: true)
  end

  class MasterFiles < Dry::Struct
    attribute :general_ledger_accounts, Types::Array.of(Account).optional.meta(omittable: true)
    # ignored since xsd said "Not in use."
    # attribute :taxonomies, Taxonomies
    attribute :customers, Types::Array.of(Customer).optional.meta(omittable: true)
    attribute :suppliers, Types::Array.of(Supplier).optional.meta(omittable: true)
    attribute :tax_table, Types::Array.of(TaxTableEntry).optional.meta(omittable: true)
    # ignored since xsd said "Not in use."
    # attribute :uom_table, UOMTable
    attribute :analysis_type_table, Types::Array.of(AnalysisTypeTableEntry).optional.meta(omittable: true)
    # ignored since xsd said "Not in use."
    # attribute :movement_type_table, MovementTypeTable
    # ignored since xsd said "Not in use."
    # attribute :products, Products
    # ignored since xsd said "Not in use."
    # attribute :physical_stock, PhysicalStock
    attribute :owners, Types::Array.of(Owner).optional.meta(omittable: true)
    # ignored since xsd said "Not in use."
    # attribute :assets, Assets
  end

  class Line < Dry::Struct
    attribute :record_id, SAFshorttextType
    attribute :account_id, SAFmiddle2textType
    attribute :analyses, Types::Array.of(AnalysisStructure).optional.meta(omittable: true)
    attribute :value_date, Types::Date.optional.meta(omittable: true)
    attribute :source_document_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :customer_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :supplier_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :description, SAFlongtextType
    attribute :debit_amount, AmountStructure.optional.meta(omittable: true)
    attribute :credit_amount, AmountStructure.optional.meta(omittable: true)
    attribute :tax_information, Types::Array.of(TaxInformationStructure).optional.meta(omittable: true)
    attribute :reference_number, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :cid, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :due_date, Types::Date.optional.meta(omittable: true)
    attribute :quantity, SAFquantityType.optional.meta(omittable: true)
    attribute :cross_reference, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :system_entry_time, Types::DateTime.optional.meta(omittable: true)
    attribute :owner_id, SAFmiddle1textType.optional.meta(omittable: true)
  end

  class Transaction < Dry::Struct
    attribute :transaction_id, SAFmiddle2textType
    attribute :period, Types::Integer
    attribute :period_year, Types::Integer
    attribute :transaction_date, Types::Date
    attribute :source_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :transaction_type, SAFshorttextType.optional.meta(omittable: true)
    attribute :description, SAFlongtextType
    attribute :batch_id, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :system_entry_date, Types::Date
    attribute :gl_posting_date, Types::Date
    # ignored since xsd said "Not in use."
    # attribute :CustomerID, SAFmiddle1textType.optional.meta(omittable: true)
    # ignored since xsd said "Not in use."
    # attribute :SupplierID, SAFmiddle1textType.optional.meta(omittable: true)
    attribute :system_id, SAFshorttextType.optional.meta(omittable: true)
    attribute :lines, Types::Array.of(Line)
  end

  class Journal < Dry::Struct
    attribute :journal_id, SAFshorttextType
    attribute :description, SAFlongtextType
    attribute :type, SAFcodeType
    attribute :transactions, Types::Array.of(Transaction).optional.meta(omittable: true)
  end

  class GeneralLedgerEntries < Dry::Struct
    attribute :number_of_entries, Types::Integer
    attribute :total_debit, SAFmonetaryType
    attribute :total_credit, SAFmonetaryType
    attribute :journals, Types::Array.of(Journal).optional.meta(omittable: true)
  end

  class AuditFile < Dry::Struct
    attribute :header, Header
    attribute :master_files, MasterFiles.optional.meta(omittable: true)
    attribute :general_ledger_entries, GeneralLedgerEntries.optional.meta(omittable: true)
    # ignored since xsd said "Not in use."
    # attribute :source_documents, SourceDocuments
  end
end
