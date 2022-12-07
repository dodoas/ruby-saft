# frozen_string_literal: true

module SAFT::V2
  module Parse
    class << self
      def call(doc)
        parse(Types::AuditFile, doc)
      end

      private

      def parse(struct, xml)
        return unless xml

        case struct.name
        when Types::AuditFile.name
          {
            header: parse(Types::Header, xml.at_xpath("//Header")),
            master_files: parse(Types::MasterFiles, xml.at_xpath("//MasterFiles")),
            general_ledger_entries: parse(Types::GeneralLedgerEntries, xml.at_xpath("//GeneralLedgerEntries")),
          }.compact

        when Types::Header.name
          {
            **parse(Types::HeaderStructure, xml),
            tax_accounting_basis: xml.at_xpath("TaxAccountingBasis")&.content,
            tax_entity: xml.at_xpath("TaxEntity")&.content,
            user_id: xml.at_xpath("UserID")&.content,
            audit_file_sender: parse(Types::CompanyStructure, xml.at_xpath("AuditFileSender")),
          }.compact

        when Types::CompanyHeaderStructure.name
          {
            registration_number: xml.at_xpath("RegistrationNumber")&.content,
            name: xml.at_xpath("Name")&.content,
            addresses: xml.xpath("Address").map { |node| parse(Types::AddressStructure, node) }.then { _1.empty? ? nil : _1 },
            contacts: xml.xpath("Contact").map { |node| parse(Types::ContactInformationStructure, node) }.then { _1.empty? ? nil : _1 },
            tax_registrations: xml.xpath("TaxRegistration").map { |node| parse(Types::TaxIDStructure, node) }.then { _1.empty? ? nil : _1 },
            bank_accounts: xml.xpath("BankAccount").map { |node| parse(Types::BankAccountStructure, node) }.then { _1.empty? ? nil : _1 },
          }.compact

        when Types::CompanyStructure.name
          {
            registration_number: xml.at_xpath("RegistrationNumber")&.content,
            name: xml.at_xpath("Name")&.content,
            addresses: xml.xpath("Address").map { |node| parse(Types::AddressStructure, node) }.then { _1.empty? ? nil : _1 },
            contacts: xml.xpath("Contact").map { |node| parse(Types::ContactInformationStructure, node) }.then { _1.empty? ? nil : _1 },
            tax_registrations: xml.xpath("TaxRegistration").map { |node| parse(Types::TaxIDStructure, node) }.then { _1.empty? ? nil : _1 },
            bank_accounts: xml.xpath("BankAccount").map { |node| parse(Types::BankAccountStructure, node) }.then { _1.empty? ? nil : _1 },
          }.compact

        when Types::AddressStructure.name
          {
            street_name: xml.at_xpath("StreetName")&.content,
            number: xml.at_xpath("Number")&.content,
            additional_address_detail: xml.at_xpath("AdditionalAddressDetail")&.content,
            building: xml.at_xpath("Building")&.content,
            city: xml.at_xpath("City")&.content,
            postal_code: xml.at_xpath("PostalCode")&.content,
            region: xml.at_xpath("Region")&.content,
            country: xml.at_xpath("Country")&.content,
            address_type: xml.at_xpath("AddressType")&.content,
          }.compact

        when Types::ContactInformationStructure.name
          {
            contact_person: parse(Types::PersonNameStructure, xml.at_xpath("ContactPerson")),
            telephone: xml.at_xpath("Telephone")&.content,
            fax: xml.at_xpath("Fax")&.content,
            email: xml.at_xpath("Email")&.content,
            website: xml.at_xpath("Website")&.content,
            mobile_phone: xml.at_xpath("MobilePhone")&.content,
          }.compact

        when Types::TaxIDStructure.name
          {
            tax_registration_number: xml.at_xpath("TaxRegistrationNumber")&.content,
            # tax_type: xml.at_xpath("TaxType")&.content,
            # tax_number: xml.at_xpath("TaxNumber")&.content,
            tax_authority: xml.at_xpath("TaxAuthority")&.content,
            tax_verification_date: xml.at_xpath("TaxVerificationDate")&.content,
          }.compact

        when Types::BankAccountStructure.name
          {
            iban_number: xml.at_xpath("IBANNumber")&.content,
            bank_account_number: xml.at_xpath("BankAccountNumber")&.content,
            bank_account_name: xml.at_xpath("BankAccountName")&.content,
            sort_code: xml.at_xpath("SortCode")&.content,
            bic: xml.at_xpath("BIC")&.content,
            currency_code: xml.at_xpath("CurrencyCode")&.content,
            general_ledger_account_id: xml.at_xpath("GeneralLedgerAccountID")&.content,
          }.compact

        when Types::PersonNameStructure.name
          {
            title: xml.at_xpath("Title")&.content,
            first_name: xml.at_xpath("FirstName")&.content,
            initials: xml.at_xpath("Initials")&.content,
            last_name_prefix: xml.at_xpath("LastNamePrefix")&.content,
            last_name: xml.at_xpath("LastName")&.content,
            birth_name: xml.at_xpath("BirthName")&.content,
            salutation: xml.at_xpath("Salutation")&.content,
            other_titles: xml.xpath("OtherTitles").map(&:content).then { _1.empty? ? nil : _1 },
          }.compact

        when Types::SelectionCriteriaStructure.name
          {
            tax_reporting_jurisdiction: xml.at_xpath("TaxReportingJurisdiction")&.content,
            company_entity: xml.at_xpath("CompanyEntity")&.content,
            selection_start_date: xml.at_xpath("SelectionStartDate")&.content,
            selection_end_date: xml.at_xpath("SelectionEndDate")&.content,
            period_start: xml.at_xpath("PeriodStart")&.content,
            period_start_year: xml.at_xpath("PeriodStartYear")&.content,
            period_end: xml.at_xpath("PeriodEnd")&.content,
            period_end_year: xml.at_xpath("PeriodEndYear")&.content,
            document_type: xml.at_xpath("DocumentType")&.content,
            other_criterias: xml.xpath("OtherCriteria").map(&:content),
          }.compact

        when Types::AmountStructure.name
          {
            amount: xml.at_xpath("Amount")&.content,
            currency_code: xml.at_xpath("CurrencyCode")&.content,
            currency_amount: xml.at_xpath("CurrencyAmount")&.content,
            exchange_rate: xml.at_xpath("ExchangeRate")&.content,
          }.compact

        when Types::AnalysisStructure.name
          {
            analysis_type: xml.at_xpath("AnalysisType")&.content,
            analysis_id: xml.at_xpath("AnalysisID")&.content,
            analysis_amount: parse(Types::AmountStructure, xml.at_xpath("AnalysisAmount")),
          }.compact

        when Types::AnalysisPartyInfoStructure.name
          {
            analysis_type: xml.at_xpath("AnalysisType")&.content,
            analysis_id: xml.at_xpath("AnalysisID")&.content,
          }.compact

        when Types::TaxInformationStructure.name
          {
            tax_type: xml.at_xpath("TaxType")&.content,
            tax_code: xml.at_xpath("TaxCode")&.content,
            tax_percentage: xml.at_xpath("TaxPercentage")&.content,
            country: xml.at_xpath("Country")&.content,
            tax_base: xml.at_xpath("TaxBase")&.content,
            tax_base_description: xml.at_xpath("TaxBaseDescription")&.content,
            tax_amount: parse(Types::AmountStructure, xml.at_xpath("TaxAmount")),
            tax_exemption_reason: xml.at_xpath("TaxExemptionReason")&.content,
            tax_declaration_period: xml.at_xpath("TaxDeclarationPeriod")&.content,
          }.compact

        when Types::PaymentTerms.name
          {
            days: xml.at_xpath("Days")&.content,
            months: xml.at_xpath("Months")&.content,
            cash_discount_days: xml.at_xpath("CashDiscountDays")&.content,
            cash_discount_rate: xml.at_xpath("CashDiscountRate")&.content,
            free_billing_month: xml.at_xpath("FreeBillingMonth")&.content,
          }.compact

        when Types::PartyInfoStructure.name
          {
            payment_terms: parse(Types::PaymentTerms, xml.at_xpath("PaymentTerms")),
            nace_code: xml.at_xpath("NaceCode")&.content,
            currency_code: xml.at_xpath("CurrencyCode")&.content,
            type: xml.at_xpath("Type")&.content,
            status: xml.at_xpath("Status")&.content,
            analyses: xml.xpath("Analysis").map { |node| parse(Types::AnalysisPartyInfoStructure, node) }.then { _1.empty? ? nil : _1 },
            notes: xml.at_xpath("Notes")&.content,
          }.compact

        when Types::ShippingPointStructure.name
          {
            delivery_id: xml.at_xpath("DeliveryID")&.content,
            delivery_date: xml.at_xpath("DeliveryDate")&.content,
            warehouse_id: xml.at_xpath("WarehouseID")&.content,
            location_id: xml.at_xpath("LocationID")&.content,
            ucr: xml.at_xpath("UCR")&.content,
            address: parse(Types::AddressStructure, xml.at_xpath("Address")),
          }.compact

        when Types::HeaderStructure.name
          {
            audit_file_version: xml.at_xpath("AuditFileVersion")&.content,
            audit_file_country: xml.at_xpath("AuditFileCountry")&.content,
            audit_file_date_created: xml.at_xpath("AuditFileDateCreated")&.content,
            software_company_name: xml.at_xpath("SoftwareCompanyName")&.content,
            software_id: xml.at_xpath("SoftwareID")&.content,
            software_version: xml.at_xpath("SoftwareVersion")&.content,
            company: parse(Types::CompanyHeaderStructure, xml.at_xpath("Company")),
            default_currency_code: xml.at_xpath("DefaultCurrencyCode")&.content,
            selection_criteria: parse(Types::SelectionCriteriaStructure, xml.at_xpath("SelectionCriteria")),
            header_comment: xml.at_xpath("HeaderComment")&.content,
          }.compact

        when Types::Account.name
          {
            account_id: xml.at_xpath("AccountID")&.content,
            account_description: xml.at_xpath("AccountDescription")&.content,
            standard_account_id: xml.at_xpath("StandardAccountID")&.content,
            grouping_category: xml.at_xpath("GroupingCategory")&.content,
            grouping_code: xml.at_xpath("GroupingCode")&.content,
            account_type: xml.at_xpath("AccountType")&.content,
            account_creation_date: xml.at_xpath("AccountCreationDate")&.content,
            opening_debit_balance: xml.at_xpath("OpeningDebitBalance")&.content,
            opening_credit_balance: xml.at_xpath("OpeningCreditBalance")&.content,
            closing_debit_balance: xml.at_xpath("ClosingDebitBalance")&.content,
            closing_credit_balance: xml.at_xpath("ClosingCreditBalance")&.content,
          }.compact

        when Types::Customer.name
          {
            **parse(Types::CompanyStructure, xml),
            customer_id: xml.at_xpath("CustomerID")&.content,
            self_billing_indicator: xml.at_xpath("SelfBillingIndicator")&.content,
            account_id: xml.at_xpath("AccountID")&.content,
            opening_debit_balance: xml.at_xpath("OpeningDebitBalance")&.content,
            opening_credit_balance: xml.at_xpath("OpeningCreditBalance")&.content,
            closing_debit_balance: xml.at_xpath("ClosingDebitBalance")&.content,
            closing_credit_balance: xml.at_xpath("ClosingCreditBalance")&.content,
            party_info: parse(Types::PartyInfoStructure, xml.at_xpath("PartyInfo")),
          }.compact

        when Types::Supplier.name
          {
            **parse(Types::CompanyStructure, xml),
            supplier_id: xml.at_xpath("SupplierID")&.content,
            self_billing_indicator: xml.at_xpath("SelfBillingIndicator")&.content,
            account_id: xml.at_xpath("AccountID")&.content,
            opening_debit_balance: xml.at_xpath("OpeningDebitBalance")&.content,
            opening_credit_balance: xml.at_xpath("OpeningCreditBalance")&.content,
            closing_debit_balance: xml.at_xpath("ClosingDebitBalance")&.content,
            closing_credit_balance: xml.at_xpath("ClosingCreditBalance")&.content,
            party_info: parse(Types::PartyInfoStructure, xml.at_xpath("PartyInfo")),
          }.compact

        when Types::TaxCodeDetails.name
          {
            tax_code: xml.at_xpath("TaxCode")&.content,
            effective_date: xml.at_xpath("EffectiveDate")&.content,
            expiration_date: xml.at_xpath("ExpirationDate")&.content,
            description: xml.at_xpath("Description")&.content,
            tax_percentage: xml.at_xpath("TaxPercentage")&.content,
            # flat_tax_rate: parse(Types::AmountStructure, xml.at_xpath("FlatTaxRate")),
            country: xml.at_xpath("Country")&.content,
            # region: xml.at_xpath("Region")&.content,
            standard_tax_code: xml.at_xpath("StandardTaxCode")&.content,
            compensation: xml.at_xpath("Compensation")&.content,
            base_rates: xml.xpath("BaseRate").map(&:content),
          }.compact

        when Types::TaxTableEntry.name
          {
            tax_type: xml.at_xpath("TaxType")&.content,
            description: xml.at_xpath("Description")&.content,
            tax_code_details: xml.xpath("TaxCodeDetails").map { |node| parse(Types::TaxCodeDetails, node) }.then { _1.empty? ? nil : _1 },
          }.compact

        when Types::AnalysisTypeTableEntry.name
          {
            analysis_type: xml.at_xpath("AnalysisType")&.content,
            analysis_type_description: xml.at_xpath("AnalysisTypeDescription")&.content,
            analysis_id: xml.at_xpath("AnalysisID")&.content,
            analysis_id_description: xml.at_xpath("AnalysisIDDescription")&.content,
            start_date: xml.at_xpath("StartDate")&.content,
            end_date: xml.at_xpath("EndDate")&.content,
            status: xml.at_xpath("Status")&.content,
            analyses: xml.xpath("Analysis").map { |node| parse(Types::AnalysisPartyInfoStructure, node) }.then { _1.empty? ? nil : _1 },
          }.compact

        when Types::Owner.name
          {
            **parse(Types::CompanyStructure, xml),
            owner_id: xml.at_xpath("OwnerID")&.content,
            account_id: xml.at_xpath("AccountID")&.content,
          }

        when Types::MasterFiles.name
          {
            general_ledger_accounts: xml.xpath("GeneralLedgerAccounts/Account").map { |node| parse(Types::Account, node) }.then { _1.empty? ? nil : _1 },
            customers: xml.xpath("Customers/Customer").map { |node| parse(Types::Customer, node) }.then { _1.empty? ? nil : _1 },
            suppliers: xml.xpath("Suppliers/Supplier").map { |node| parse(Types::Supplier, node) }.then { _1.empty? ? nil : _1 },
            tax_table: xml.xpath("TaxTable/TaxTableEntry").map { |node| parse(Types::TaxTableEntry, node) }.then { _1.empty? ? nil : _1 },
            analysis_type_table: xml
              .xpath("AnalysisTypeTable/AnalysisTypeTableEntry")
              .map { |node| parse(Types::AnalysisTypeTableEntry, node) }
              .then { _1.empty? ? nil : _1 },
            owners: xml.xpath("Owners/Owner").map { |node| parse(Types::Owner, node) }.then { _1.empty? ? nil : _1 },
          }.compact

        when Types::Line.name
          {
            record_id: xml.at_xpath("RecordID")&.content,
            account_id: xml.at_xpath("AccountID")&.content,
            analyses: xml.xpath("Analysis").map { |node| parse(Types::AnalysisStructure, node) }.then { _1.empty? ? nil : _1 },
            value_date: xml.at_xpath("ValueDate")&.content,
            source_document_id: xml.at_xpath("SourceDocumentID")&.content,
            customer_id: xml.at_xpath("CustomerID")&.content,
            supplier_id: xml.at_xpath("SupplierID")&.content,
            description: xml.at_xpath("Description")&.content,
            debit_amount: parse(Types::AmountStructure, xml.at_xpath("DebitAmount")),
            credit_amount: parse(Types::AmountStructure, xml.at_xpath("CreditAmount")),
            tax_information: xml.xpath("TaxInformation").map { |node| parse(Types::TaxInformationStructure, node) }.then { _1.empty? ? nil : _1 },
            reference_number: xml.at_xpath("ReferenceNumber")&.content,
            cid: xml.at_xpath("CID")&.content,
            due_date: xml.at_xpath("DueDate")&.content,
            quantity: xml.at_xpath("Quantity")&.content,
            cross_reference: xml.at_xpath("CrossReference")&.content,
            system_entry_time: xml.at_xpath("SystemEntryTime")&.content,
            owner_id: xml.at_xpath("OwnerID")&.content,
          }.compact

        when Types::Transaction.name
          {
            transaction_id: xml.at_xpath("TransactionID")&.content,
            period: xml.at_xpath("Period")&.content,
            period_year: xml.at_xpath("PeriodYear")&.content,
            transaction_date: xml.at_xpath("TransactionDate")&.content,
            source_id: xml.at_xpath("SourceID")&.content,
            transaction_type: xml.at_xpath("TransactionType")&.content,
            description: xml.at_xpath("Description")&.content,
            batch_id: xml.at_xpath("BatchID")&.content,
            system_entry_date: xml.at_xpath("SystemEntryDate")&.content,
            gl_posting_date: xml.at_xpath("GLPostingDate")&.content,
            system_id: xml.at_xpath("SystemID")&.content,
            lines: xml.xpath("Line").map { |node| parse(Types::Line, node) }.then { _1.empty? ? nil : _1 },
          }.compact

        when Types::Journal.name
          {
            journal_id: xml.at_xpath("JournalID")&.content,
            description: xml.at_xpath("Description")&.content,
            type: xml.at_xpath("Type")&.content,
            transactions: xml.xpath("Transaction").map { |node| parse(Types::Transaction, node) }.then { _1.empty? ? nil : _1 },
          }.compact

        when Types::GeneralLedgerEntries.name
          {
            number_of_entries: xml.at_xpath("NumberOfEntries")&.content,
            total_debit: xml.at_xpath("TotalDebit")&.content,
            total_credit: xml.at_xpath("TotalCredit")&.content,
            journals: xml.xpath("Journal").map { |node| parse(Types::Journal, node) }.then { _1.empty? ? nil : _1 },
          }.compact
        end
      end
    end
  end
end
