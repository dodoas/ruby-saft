# frozen_string_literal: true

require "date"
require "bigdecimal"

require "pp" # rubocop:disable Lint/RedundantRequireStatement
require "deep_compact"

RSpec.describe SAFT::V2 do
  using(DeepCompact)

  RSpec::Matchers.define(:hash_has_same_data) do |expected|
    match do |actual|
      @expected = expected.deep_compact
      @actual = actual.deep_compact

      @expected == @actual
    end

    diffable

    def actual
      @actual.pretty_inspect
    end

    def expected
      @expected.pretty_inspect
    end

    def failure_message
      <<~MESSAGE
        expected: some hash
             got: some other hash
      MESSAGE
    end
  end

  def be_xsd_valid
    have_attributes(valid?: true, errors: [])
  end

  let(:minimal_valid) {
    {
      header: {
        audit_file_version: "1.10",
        audit_file_country: "NO",
        audit_file_date_created: Date.civil(2022, 11, 14),
        software_company_name: "Example",
        software_id: "Example.no",
        software_version: "1.0",
        default_currency_code: "NOK",
        tax_accounting_basis: "A",
        company: {
          registration_number: "Regi",
          name: "Nan AS",
          addresses: [{}],
          contacts: [
            {
              contact_person: {
                first_name: "Joe",
                last_name: "Doe",
              },
            },
          ],
        },
      },
    }
  }

  it "write and read minimal file" do
    described_class::Types::AuditFile[minimal_valid]
      .then { described_class.scribe(_1) }
      .tap { expect(described_class.validate(_1)).to(be_xsd_valid) }
      .then { described_class.parse(_1) }
      .tap { expect(_1.to_hash).to(hash_has_same_data(minimal_valid)) }
  end

  it "validate return false when invalid with errors" do
    minimal_valid[:master_files] = {
      general_ledger_accounts: [
        {
          account_id: "1920",
          account_description: "Bank Account",
          standard_account_id: "19",
          account_type: "GL",
          account_creation_date: Date.civil(1998, 1, 1),
        },
      ],
    }

    content = described_class::Types::AuditFile[minimal_valid].then { described_class.scribe(_1) }
    expect(described_class.validate(content))
      .to(
        have_attributes(
          valid?: false,
          errors: [
            have_attributes(
              to_s: "26:0: ERROR: Element '{urn:StandardAuditFile-Taxation-Financial:NO}Account': Missing child element(s). Expected is one of ( {urn:StandardAuditFile-Taxation-Financial:NO}OpeningDebitBalance, {urn:StandardAuditFile-Taxation-Financial:NO}OpeningCreditBalance ).",
            ),
          ],
        ),
      )
  end

  describe "Work with big file" do
    bigest = {
      header: {
        audit_file_version: "1.10",
        audit_file_country: "NO",
        audit_file_date_created: Date.civil(2022, 11, 14),
        software_company_name: "AccWare",
        software_id: "AccWare.no",
        software_version: "1.0",
        company: {
          registration_number: "101102103",
          name: "Ice ice baby",
          addresses: [
            {
              street_name: "Cold street",
              number: "4",
              additional_address_detail: "Gate C",
              building: "L",
              city: "Ice flak",
              postal_code: "0000",
              region: "South pole",
              country: "XX",
              address_type: "PostalAddress",
            },
            {
              street_name: "Slight less cold street",
            },
          ],
          contacts: [
            {
              contact_person: {
                title: "Director",
                first_name: "Iselin",
                initials: "IS",
                last_name_prefix: "Von",
                last_name: "Syringe",
                birth_name: "Joe",
                salutation: "Holy lowly mac sir",
                other_titles: ["Director", "Manager", "Worker"],
              },
              telephone: "+00101010101",
              fax: "65468156",
              email: "ice@ice.baby",
              website: "ice.baby",
              mobile_phone: "+00101010101",
            },
            {
              contact_person: {
                first_name: "Tor",
                last_name: "Incognito",
              },
            },
          ],
          tax_registrations: [
            {
              tax_registration_number: "3159MVA",
              tax_authority: "Skatteetaten",
              tax_verification_date: Date.civil(2020, 1, 1),
            },
            {
              tax_registration_number: "NO3159MVA",
              tax_authority: "Skatteetaten",
            },
          ],
          bank_accounts: [
            {
              iban_number: "NO000000123123",
              bic: "NOFO",
              currency_code: "NOK",
              general_ledger_account_id: "1920",
            },
            {
              bank_account_number: "005500550044",
              bank_account_name: "High interest",
              sort_code: "95",
            },
            {
              iban_number: "NO00000019549",
            },
          ],
        },
        default_currency_code: "NOK",
        selection_criteria: {
          tax_reporting_jurisdiction: "The pinup man",
          company_entity: "The pinup CO",
          selection_start_date: Date.civil(2020, 1, 1),
          selection_end_date: Date.civil(2020, 12, 31),
          document_type: "All kind are included",
          other_criterias: ["Elm is cool", "Ruby is cool", "Javascript is \"cool\""],
        },
        header_comment: "SAF-T financial accounting export by AccWare. 14. november 2022 07:14",
        tax_accounting_basis: "A",
        tax_entity: "Company / Division / Branch",
        user_id: "Isabel",
        audit_file_sender: {
          registration_number: "NO909819",
          name: "Mc been",
          addresses: [
            {
              street_name: "std2",
            },
            {
              street_name: "std3",
            },
          ],
          contacts: [
            {
              contact_person: {
                first_name: "std4",
                last_name: "std5",
              },
            },
            {
              contact_person: {
                first_name: "std6",
                last_name: "std7",
              },
            },
          ],
          tax_registrations: [
            {
              tax_registration_number: "std8",
              tax_authority: "Skatteetaten",
            },
            {
              tax_registration_number: "std9",
              tax_authority: "Skatteetaten",
            },
          ],
          bank_accounts: [
            {
              iban_number: "std10",
            },
            {
              iban_number: "std10",
            },
          ],
        },
      },
      master_files: {
        general_ledger_accounts: [
          {
            account_id: "1920",
            account_description: "Bank Account",
            standard_account_id: "19",
            grouping_category: "A",
            grouping_code: "A",
            account_type: "GL",
            account_creation_date: Date.civil(1998, 1, 1),
            opening_debit_balance: BigDecimal("10.0"),
            closing_debit_balance: BigDecimal("12.0"),
          },
          {
            account_id: "1920",
            account_description: "Bank Account",
            account_type: "GL",
            opening_credit_balance: BigDecimal("12.0"),
            closing_credit_balance: BigDecimal("13.0"),
          },
        ],
        customers: [
          {
            name: "Acme",
            addresses: [
              {},
            ],
            customer_id: "C1",
            self_billing_indicator: "No",
            account_id: "1500:12",
            opening_debit_balance: BigDecimal("1.0"),
            closing_debit_balance: BigDecimal("2.0"),
            party_info: {
              payment_terms: {
                days: 5,
                months: 1,
                cash_discount_days: 10,
                cash_discount_rate: BigDecimal("8.41"),
                free_billing_month: true,
              },
              nace_code: "Nice",
              currency_code: "SEK",
              type: "Company",
              status: "Active",
              analyses: [
                {analysis_type: "PRO", analysis_id: "1"},
                {analysis_type: "PRO", analysis_id: "2"},
              ],
              notes: "Secrets ***************",
            },
          },
          {
            name: "Acme the second",
            addresses: [
              {},
            ],
            customer_id: "C2",
            opening_credit_balance: BigDecimal("3.0"),
            closing_credit_balance: BigDecimal("4.0"),
          },
          {
            name: "Acme the Suied",
            addresses: [
              {},
            ],
            customer_id: "C3",
          },
        ],
        suppliers: [
          {
            name: "Been",
            addresses: [
              {},
            ],
            supplier_id: "S1",
            self_billing_indicator: "No",
            account_id: "1500:12",
            opening_debit_balance: BigDecimal("1.0"),
            closing_debit_balance: BigDecimal("2.0"),
            party_info: {
              payment_terms: {
                days: 5,
                months: 1,
                cash_discount_days: 10,
                cash_discount_rate: BigDecimal("8.41"),
                free_billing_month: true,
              },
              nace_code: "Nice",
              currency_code: "SEK",
              type: "Company",
              status: "Active",
              analyses: [
                {analysis_type: "PRO", analysis_id: "1"},
                {analysis_type: "PRO", analysis_id: "2"},
              ],
              notes: "Secrets ***************",
            },
          },
          {
            name: "Been the second",
            addresses: [
              {},
            ],
            supplier_id: "S2",
            opening_credit_balance: BigDecimal("3.0"),
            closing_credit_balance: BigDecimal("4.0"),
          },
          {
            name: "Been the Suied",
            addresses: [
              {},
            ],
            supplier_id: "S3",
          },
        ],
        tax_table: [
          {
            tax_type: "MVA",
            description: "Merverdiavgift",
            tax_code_details: [
              {
                tax_code: "52",
                effective_date: Date.civil(2020, 1, 1),
                expiration_date: Date.civil(2030, 1, 1),
                description: "TAX with code 52",
                tax_percentage: BigDecimal("15.0"),
                country: "No",
                standard_tax_code: "15",
                compensation: true,
                base_rates: [BigDecimal("100"), BigDecimal("98.0")],
              },
              {
                tax_code: "53",
                country: "No",
                standard_tax_code: "16",
                base_rates: [BigDecimal("100.0")],
              },
            ],
          },
          {
            tax_type: "MVA",
            description: "Merverdiavgift",
            tax_code_details: [
              {
                tax_code: "53",
                country: "No",
                standard_tax_code: "16",
                base_rates: [BigDecimal("100.0")],
              },
            ],
          },
        ],
        analysis_type_table: [
          {
            analysis_type: "T",
            analysis_type_description: "Type of voucher",
            analysis_id: "M",
            analysis_id_description: "Manual",
            start_date: Date.civil(2018, 1, 1),
            end_date: Date.civil(2028, 1, 1),
            status: "Active",
            analyses: [
              {analysis_type: "K", analysis_id: "1"},
              {analysis_type: "K", analysis_id: "2"},
            ],
          },
          {
            analysis_type: "T",
            analysis_type_description: "Type of voucher",
            analysis_id: "B",
            analysis_id_description: "Bank",
          },
        ],
        owners: [
          {
            name: "Been O'reily",
            addresses: [
              {},
            ],
            owner_id: "ow15",
            account_id: "2940:5",
          },
          {
            name: "mr Been",
            addresses: [
              {},
            ],
          },
        ],
      },
      general_ledger_entries: {
        number_of_entries: 5,
        total_debit: BigDecimal("6.0"),
        total_credit: BigDecimal("7.0"),
        journals: [
          {
            journal_id: "Jo1",
            description: "Journal number 1",
            type: "no idea",
            transactions: [
              {
                transaction_id: "Tra1",
                period: 3,
                period_year: 2020,
                transaction_date: Date.civil(2020, 3, 10),
                source_id: "Boho",
                transaction_type: "normal",
                description: "From the bank",
                batch_id: "12",
                system_entry_date: Date.civil(2020, 3, 12),
                gl_posting_date: Date.civil(2020, 3, 10),
                system_id: "12-651-8951",
                lines: [
                  {
                    record_id: "line-18",
                    account_id: "1920",
                    analyses: [
                      {
                        analysis_type: "PRO",
                        analysis_id: "1",
                      },
                      {
                        analysis_type: "PRO",
                        analysis_id: "2",
                      },
                    ],
                    value_date: Date.civil(2020, 3, 10),
                    source_document_id: "159",
                    customer_id: "15",
                    description: "Something",
                    debit_amount: {
                      amount: BigDecimal("598.0"),
                    },
                    tax_information: [
                      {
                        tax_type: "MVA",
                        tax_code: "52",
                        tax_percentage: BigDecimal("25.0"),
                        country: "NO",
                        tax_base: BigDecimal("9000.0"),
                        tax_base_description: "Some random description",
                        tax_amount: {
                          amount: BigDecimal("593.0"),
                        },
                        tax_exemption_reason: "550",
                        tax_declaration_period: "2020-04",
                      },
                      {
                        tax_amount: {
                          amount: BigDecimal("5.0"),
                        },
                      },
                    ],
                    reference_number: "1512",
                    cid: "21",
                    due_date: Date.civil(2020, 4, 10),
                    quantity: BigDecimal("2020"),
                    cross_reference: "189",
                    system_entry_time: DateTime.parse("2020-04-30T00:00:08"),
                    owner_id: "Ow-2",
                  },
                  {
                    record_id: "line-18",
                    account_id: "1921",
                    supplier_id: "13",
                    description: "Something new",
                    credit_amount: {
                      amount: BigDecimal("593.0"),
                    },
                  },
                ],
              },
              {
                transaction_id: "Tra2",
                period: 3,
                period_year: 2020,
                transaction_date: Date.civil(2020, 3, 10),
                description: "From the bank",
                system_entry_date: Date.civil(2020, 3, 12),
                gl_posting_date: Date.civil(2020, 3, 10),
                lines: [
                  {
                    record_id: "line-18",
                    account_id: "1921",
                    supplier_id: "13",
                    description: "Something new",
                    credit_amount: {
                      amount: BigDecimal("123.0"),
                      currency_code: "SEK",
                      currency_amount: BigDecimal("110.0"),
                      exchange_rate: BigDecimal("99.56"),
                    },
                  },
                ],
              },
            ],
          },
          {
            journal_id: "Jo2",
            description: "Journal number 2",
            type: "no idea",
          },
        ],
      },
    }

    it "can write and parse header" do
      data = {
        header: bigest[:header],
      }

      described_class::Types::AuditFile[data]
        .then { described_class.scribe(_1) }
        .tap { expect(described_class.validate(_1)).to(be_xsd_valid) }
        .then { described_class.parse(_1) }
        .tap { expect(_1.to_hash).to(hash_has_same_data(data)) }
    end

    it "full file" do
      described_class::Types::AuditFile[bigest]
        .then { described_class.scribe(_1) }
        .tap { expect(described_class.validate(_1)).to(be_xsd_valid) }
        .then { described_class.parse(_1) }
        .tap { expect(_1.to_hash).to(hash_has_same_data(bigest)) }
    end
  end
end
