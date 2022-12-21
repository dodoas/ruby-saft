# frozen_string_literal: true

module SAFT::V2
  class Scribe
    def self.write_xml(audit_file)
      new.write_xml(audit_file)
    end

    def write_xml(audit_file)
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        build_the_xml(xml, audit_file)
      end

      builder.to_xml(save_with: SAFT.nokogiri_save_setting)
    end

    private

    attr_reader(:xml)

    def build_the_xml(xml, audit_file)
      # avoid passing the xml builder instance
      @xml = xml
      namespaces = {"xmlns" => "urn:StandardAuditFile-Taxation-Financial:NO"}
      xml.AuditFile(namespaces) do
        build(audit_file)
      end

      @xml = nil
    end

    def build_company_structure(struct)
      xml.RegistrationNumber(struct.registration_number) if struct.registration_number
      xml.Name(struct.name) if struct.name
      struct.addresses&.each { |address| xml.Address { build(address) } }
      struct.contacts&.each { |contact| xml.Contact { build(contact) } }
      struct.tax_registrations&.each { |tax_registration| xml.TaxRegistration { build(tax_registration) } }
      struct.bank_accounts&.each { |bank_account| xml.BankAccount { build(bank_account) } }
    end

    def build(struct)
      return unless struct

      klass = struct.class.ancestors.detect { _1.name&.start_with?("SAFT::V2") }
      # We do .name.split("::").last because this has to support all three types
      case klass.name.split("::").last
      when Types::AuditFile.name.split("::").last
        xml.Header { build(struct.header) }
        if struct.master_files
          xml.MasterFiles { build(struct.master_files) }
        end
        if struct.general_ledger_entries
          xml.GeneralLedgerEntries { build(struct.general_ledger_entries) }
        end

      when Types::Header.name.split("::").last
        xml.AuditFileVersion(struct.audit_file_version)
        xml.AuditFileCountry(struct.audit_file_country)
        xml.AuditFileDateCreated(struct.audit_file_date_created)
        xml.SoftwareCompanyName(struct.software_company_name)
        xml.SoftwareID(struct.software_id)
        xml.SoftwareVersion(struct.software_version)
        xml.Company { build(struct.company) }
        xml.DefaultCurrencyCode(struct.default_currency_code)
        xml.SelectionCriteria { build(struct.selection_criteria) } if struct.selection_criteria
        xml.HeaderComment(struct.header_comment) if struct.header_comment
        xml.TaxAccountingBasis(struct.tax_accounting_basis)
        xml.TaxEntity(struct.tax_entity) if struct.tax_entity
        xml.UserID(struct.user_id) if struct.user_id
        xml.AuditFileSender { build(struct.audit_file_sender) } if struct.audit_file_sender

      when Types::Customer.name.split("::").last
        build_company_structure(struct)
        xml.CustomerID(struct.customer_id)
        xml.SelfBillingIndicator(struct.self_billing_indicator) if struct.self_billing_indicator
        xml.AccountID(struct.account_id) if struct.account_id
        xml.OpeningDebitBalance(struct.opening_debit_balance.to_s("F")) if struct.opening_debit_balance
        xml.OpeningCreditBalance(struct.opening_credit_balance.to_s("F")) if struct.opening_credit_balance
        xml.ClosingDebitBalance(struct.closing_debit_balance.to_s("F")) if struct.closing_debit_balance
        xml.ClosingCreditBalance(struct.closing_credit_balance.to_s("F")) if struct.closing_credit_balance
        xml.PartyInfo { build(struct.party_info) } if struct.party_info

      when Types::Supplier.name.split("::").last
        build_company_structure(struct)
        xml.SupplierID(struct.supplier_id)
        xml.SelfBillingIndicator(struct.self_billing_indicator) if struct.self_billing_indicator
        xml.AccountID(struct.account_id) if struct.account_id
        xml.OpeningDebitBalance(struct.opening_debit_balance.to_s("F")) if struct.opening_debit_balance
        xml.OpeningCreditBalance(struct.opening_credit_balance.to_s("F")) if struct.opening_credit_balance
        xml.ClosingDebitBalance(struct.closing_debit_balance.to_s("F")) if struct.closing_debit_balance
        xml.ClosingCreditBalance(struct.closing_credit_balance.to_s("F")) if struct.closing_credit_balance
        xml.PartyInfo { build(struct.party_info) } if struct.party_info

      when Types::Owner.name.split("::").last
        build_company_structure(struct)
        xml.OwnerID(struct.owner_id) if struct.owner_id
        xml.AccountID(struct.account_id) if struct.account_id

      when Types::CompanyHeaderStructure.name.split("::").last
        build_company_structure(struct)

      when Types::CompanyStructure.name.split("::").last
        build_company_structure(struct)

      when Types::AddressStructure.name.split("::").last
        xml.StreetName(struct.street_name) if struct.street_name
        xml.Number(struct.number) if struct.number
        xml.AdditionalAddressDetail(struct.additional_address_detail) if struct.additional_address_detail
        xml.Building(struct.building) if struct.building
        xml.City(struct.city) if struct.city
        xml.PostalCode(struct.postal_code) if struct.postal_code
        xml.Region(struct.region) if struct.region
        xml.Country(struct.country) if struct.country
        xml.AddressType(struct.address_type) if struct.address_type

      when Types::ContactInformationStructure.name.split("::").last
        xml.ContactPerson { build(struct.contact_person) }
        xml.Telephone(struct.telephone) if struct.telephone
        xml.Fax(struct.fax) if struct.fax
        xml.Email(struct.email) if struct.email
        xml.Website(struct.website) if struct.website
        xml.MobilePhone(struct.mobile_phone) if struct.mobile_phone

      when Types::TaxIDStructure.name.split("::").last
        xml.TaxRegistrationNumber(struct.tax_registration_number)
        xml.TaxAuthority(struct.tax_authority) if struct.tax_authority
        xml.TaxVerificationDate(struct.tax_verification_date) if struct.tax_verification_date

      when Types::BankAccountStructure.name.split("::").last
        xml.IBANNumber(struct.iban_number) if struct.iban_number
        xml.BankAccountNumber(struct.bank_account_number) if struct.bank_account_number
        xml.BankAccountName(struct.bank_account_name) if struct.bank_account_name
        xml.SortCode(struct.sort_code) if struct.sort_code
        xml.BIC(struct.bic) if struct.bic
        xml.CurrencyCode(struct.currency_code) if struct.currency_code
        xml.GeneralLedgerAccountID(struct.general_ledger_account_id) if struct.general_ledger_account_id

      when Types::PersonNameStructure.name.split("::").last
        xml.Title(struct.title) if struct.title
        xml.FirstName(struct.first_name)
        xml.Initials(struct.initials) if struct.initials
        xml.LastNamePrefix(struct.last_name_prefix) if struct.last_name_prefix
        xml.LastName(struct.last_name)
        xml.BirthName(struct.birth_name) if struct.birth_name
        xml.Salutation(struct.salutation) if struct.salutation
        struct.other_titles&.each { xml.OtherTitles(_1) }

      when Types::SelectionCriteriaStructure.name.split("::").last
        xml.TaxReportingJurisdiction(struct.tax_reporting_jurisdiction) if struct.tax_reporting_jurisdiction
        xml.CompanyEntity(struct.company_entity) if struct.company_entity
        xml.SelectionStartDate(struct.selection_start_date) if struct.selection_start_date
        xml.SelectionEndDate(struct.selection_end_date) if struct.selection_end_date
        xml.PeriodStart(struct.period_start) if struct.period_start
        xml.PeriodStartYear(struct.period_start_year) if struct.period_start_year
        xml.PeriodEnd(struct.period_end) if struct.period_end
        xml.PeriodEndYear(struct.period_end_year) if struct.period_end_year
        xml.DocumentType(struct.document_type) if struct.document_type
        struct.other_criterias&.each { |criteria| xml.OtherCriteria(criteria) }

      when Types::AmountStructure.name.split("::").last
        xml.Amount(struct.amount.to_s("F"))
        xml.CurrencyCode(struct.currency_code) if struct.currency_code
        xml.CurrencyAmount(struct.currency_amount.to_s("F")) if struct.currency_amount
        xml.ExchangeRate(struct.exchange_rate.to_s("F")) if struct.exchange_rate

      when Types::AnalysisStructure.name.split("::").last
        xml.AnalysisType(struct.analysis_type) if struct.analysis_type
        xml.AnalysisID(struct.analysis_id) if struct.analysis_id
        xml.AnalysisAmount { build(struct.analysis_amount) } if struct.analysis_amount

      when Types::AnalysisPartyInfoStructure.name.split("::").last
        xml.AnalysisType(struct.analysis_type)
        xml.AnalysisID(struct.analysis_id)

      when Types::TaxInformationStructure.name.split("::").last
        xml.TaxType(struct.tax_type) if struct.tax_type
        xml.TaxCode(struct.tax_code) if struct.tax_code
        xml.TaxPercentage(struct.tax_percentage.to_s("F")) if struct.tax_percentage
        xml.Country(struct.country) if struct.country
        xml.TaxBase(struct.tax_base.to_s("F")) if struct.tax_base
        xml.TaxBaseDescription(struct.tax_base_description) if struct.tax_base_description
        xml.TaxAmount { build(struct.tax_amount) }
        xml.TaxExemptionReason(struct.tax_exemption_reason) if struct.tax_exemption_reason
        xml.TaxDeclarationPeriod(struct.tax_declaration_period) if struct.tax_declaration_period

      when Types::PaymentTerms.name.split("::").last
        xml.Days(struct.days) if struct.days
        xml.Months(struct.months) if struct.months
        xml.CashDiscountDays(struct.cash_discount_days) if struct.cash_discount_days
        xml.CashDiscountRate(struct.cash_discount_rate.to_s("F")) if struct.cash_discount_rate
        xml.FreeBillingMonth(struct.free_billing_month) if struct.free_billing_month

      when Types::PartyInfoStructure.name.split("::").last
        xml.PaymentTerms { build(struct.payment_terms) } if struct.payment_terms
        xml.NaceCode(struct.nace_code) if struct.nace_code
        xml.CurrencyCode(struct.currency_code) if struct.currency_code
        xml.Type(struct.type) if struct.type
        xml.Status(struct.status) if struct.status
        struct.analyses&.each { |analysis| xml.Analysis { build(analysis) } }
        xml.Notes(struct.notes) if struct.notes

      when Types::ShippingPointStructure.name.split("::").last
        xml.DeliveryID(struct.delivery_id) if struct.delivery_id
        xml.DeliveryDate(struct.delivery_date) if struct.delivery_date
        xml.WarehouseID(struct.warehouse_id) if struct.warehouse_id
        xml.LocationID(struct.location_id) if struct.location_id
        xml.UCR(struct.ucr) if struct.ucr
        xml.Address(struct.address) if struct.address

      when Types::HeaderStructure.name.split("::").last
        xml.AuditFileVersion(struct.audit_file_version)
        xml.AuditFileCountry(struct.audit_file_country)
        xml.AuditFileDateCreated(struct.audit_file_date_created)
        xml.SoftwareCompanyName(struct.software_company_name)
        xml.SoftwareID(struct.software_id)
        xml.SoftwareVersion(struct.software_version)
        xml.Company { build(struct.company) }
        xml.DefaultCurrencyCode(struct.default_currency_code)
        xml.SelectionCriteria { build(struct.selection_criteria) } if struct.selection_criteria
        xml.HeaderComment(struct.header_comment) if struct.header_comment

      when Types::Account.name.split("::").last
        xml.AccountID(struct.account_id)
        xml.AccountDescription(struct.account_description)
        xml.StandardAccountID(struct.standard_account_id) if struct.standard_account_id
        xml.GroupingCategory(struct.grouping_category) if struct.grouping_category
        xml.GroupingCode(struct.grouping_code) if struct.grouping_code
        xml.AccountType(struct.account_type)
        xml.AccountCreationDate(struct.account_creation_date) if struct.account_creation_date
        xml.OpeningDebitBalance(struct.opening_debit_balance.to_s("F")) if struct.opening_debit_balance
        xml.OpeningCreditBalance(struct.opening_credit_balance.to_s("F")) if struct.opening_credit_balance
        xml.ClosingDebitBalance(struct.closing_debit_balance.to_s("F")) if struct.closing_debit_balance
        xml.ClosingCreditBalance(struct.closing_credit_balance.to_s("F")) if struct.closing_credit_balance

      when Types::TaxCodeDetails.name.split("::").last
        xml.TaxCode(struct.tax_code)
        xml.EffectiveDate(struct.effective_date) if struct.effective_date
        xml.ExpirationDate(struct.expiration_date) if struct.expiration_date
        xml.Description(struct.description) if struct.description
        xml.TaxPercentage(struct.tax_percentage.to_s("F")) if struct.tax_percentage
        xml.Country(struct.country)
        xml.StandardTaxCode(struct.standard_tax_code)
        xml.Compensation(struct.compensation) if struct.compensation
        struct.base_rates&.each { xml.BaseRate(_1.to_s("F")) }

      when Types::TaxTableEntry.name.split("::").last
        xml.TaxType(struct.tax_type) if struct.tax_type
        xml.Description(struct.description) if struct.description
        struct.tax_code_details&.each { |tax_code_detail| xml.TaxCodeDetails { build(tax_code_detail) } }

      when Types::AnalysisTypeTableEntry.name.split("::").last
        xml.AnalysisType(struct.analysis_type)
        xml.AnalysisTypeDescription(struct.analysis_type_description)
        xml.AnalysisID(struct.analysis_id)
        xml.AnalysisIDDescription(struct.analysis_id_description)
        xml.StartDate(struct.start_date) if struct.start_date
        xml.EndDate(struct.end_date) if struct.end_date
        xml.Status(struct.status) if struct.status
        struct.analyses&.each { |analysis| xml.Analysis { build(analysis) } }

      when Types::MasterFiles.name.split("::").last
        if struct.general_ledger_accounts
          xml.GeneralLedgerAccounts {
            struct.general_ledger_accounts.each do |account|
              xml.Account { build(account) }
            end
          }
        end

        if struct.customers
          xml.Customers {
            struct.customers.each do |customer|
              xml.Customer { build(customer) }
            end
          }
        end

        if struct.suppliers
          xml.Suppliers {
            struct.suppliers.each do |supplier|
              xml.Supplier { build(supplier) }
            end
          }
        end

        if struct.tax_table
          xml.TaxTable {
            struct.tax_table.each do |tax_table_entry|
              xml.TaxTableEntry { build(tax_table_entry) }
            end
          }
        end

        if struct.analysis_type_table
          xml.AnalysisTypeTable {
            struct.analysis_type_table.each do |analysis_type_table_entry|
              xml.AnalysisTypeTableEntry { build(analysis_type_table_entry) }
            end
          }
        end

        if struct.owners
          xml.Owners {
            struct.owners.each do |owner|
              xml.Owner { build(owner) }
            end
          }
        end

      when Types::Line.name.split("::").last
        xml.RecordID(struct.record_id)
        xml.AccountID(struct.account_id)
        struct.analyses&.each { |analysis| xml.Analysis { build(analysis) } }
        xml.ValueDate(struct.value_date) if struct.value_date
        xml.SourceDocumentID(struct.source_document_id) if struct.source_document_id
        xml.CustomerID(struct.customer_id) if struct.customer_id
        xml.SupplierID(struct.supplier_id) if struct.supplier_id
        xml.Description(struct.description)
        xml.DebitAmount { build(struct.debit_amount) } if struct.debit_amount
        xml.CreditAmount { build(struct.credit_amount) } if struct.credit_amount
        struct.tax_information&.each { |tax_information| xml.TaxInformation { build(tax_information) } }
        xml.ReferenceNumber(struct.reference_number) if struct.reference_number
        xml.CID(struct.cid) if struct.cid
        xml.DueDate(struct.due_date) if struct.due_date
        xml.Quantity(struct.quantity.to_s("F")) if struct.quantity
        xml.CrossReference(struct.cross_reference) if struct.cross_reference
        xml.SystemEntryTime(struct.system_entry_time.strftime("%FT%T")) if struct.system_entry_time
        xml.OwnerID(struct.owner_id) if struct.owner_id

      when Types::Transaction.name.split("::").last
        xml.TransactionID(struct.transaction_id) if struct.transaction_id
        xml.Period(struct.period) if struct.period
        xml.PeriodYear(struct.period_year) if struct.period_year
        xml.TransactionDate(struct.transaction_date) if struct.transaction_date
        xml.SourceID(struct.source_id) if struct.source_id
        xml.TransactionType(struct.transaction_type) if struct.transaction_type
        xml.Description(struct.description) if struct.description
        xml.BatchID(struct.batch_id) if struct.batch_id
        xml.SystemEntryDate(struct.system_entry_date) if struct.system_entry_date
        xml.GLPostingDate(struct.gl_posting_date) if struct.gl_posting_date
        xml.SystemID(struct.system_id) if struct.system_id
        struct.lines&.each do |line|
          xml.Line { build(line) }
        end

      when Types::Journal.name.split("::").last
        xml.JournalID(struct.journal_id) if struct.journal_id
        xml.Description(struct.description) if struct.description
        xml.Type(struct.type) if struct.type
        struct.transactions&.each do |transaction|
          xml.Transaction { build(transaction) }
        end

      when Types::GeneralLedgerEntries.name.split("::").last
        xml.NumberOfEntries(struct.number_of_entries) if struct.number_of_entries
        xml.TotalDebit(struct.total_debit.to_s("F")) if struct.total_debit
        xml.TotalCredit(struct.total_credit.to_s("F")) if struct.total_credit
        struct.journals&.each do |journal|
          xml.Journal { build(journal) }
        end
      end
    end
  end
end
