# frozen_string_literal: true

require "dry-struct"
require "tubby"

module SAFT::V2
  module HTML
    def self.css
      File.read(css_path)
    end

    def self.css_path
      Pathname.new(__dir__) + "html_dist.css"
    end

    def self.format_big_decimal(big_decimal)
      negative = big_decimal.negative?
      integer, decimal = big_decimal.abs.to_s("F").split(".")
      integer = integer.reverse.scan(/.{1,3}/).join(" ").reverse

      "#{negative ? "-" : ""}#{integer},#{decimal.ljust(2, "0")}"
    end

    module DryStructRenderTubby
      refine(String) do
        def to_tubby
          self
        end
      end

      refine(Date) do
        def to_tubby
          to_s
        end
      end

      refine(NilClass) do
        def to_tubby
          "-"
        end
      end

      refine(DateTime) do
        def to_tubby
          to_s
        end
      end

      refine(Integer) do
        def to_tubby
          to_s
        end
      end

      refine(BigDecimal) do
        def to_tubby
          HTML.format_big_decimal(self)
        end
      end

      refine(Array) do
        def to_tubby
          Tubby.new { |t| each { t << _1 } }
        end
      end

      refine(Dry::Struct) do
        def to_tubby
          Tubby.new { |t| t.div(class: "mb-2 pl-2 border-l-2") { t << RenderHash.new(attributes) } }
        end
      end

      refine(SAFT::V2::Types::AuditFile) do
        def to_tubby
          Tubby.new { |t|
            t.div(class: "pl-2 border-l-2") {
              t.div(class: "mb-2 border-b-2") { t.strong("Header") }
              t << RenderHash.new(header.attributes)
            }

            if master_files
              t.div(class: "pl-2 border-l-2") {
                t.div(class: "mb-2 border-b-2") { t.strong("MasterFiles") }
                t << master_files
              }
            end

            if general_ledger_entries
              t.div(class: "pl-2 border-l-2") {
                t.div(class: "mb-2 border-b-2") { t.strong("GeneralLedgerEntries") }
                t << general_ledger_entries
              }
            end
          }
        end
      end

      refine(SAFT::V2::Types::MasterFiles) do
        def to_tubby
          Tubby.new { |t|
            if general_ledger_accounts
              t.strong("General ledger accounts")
              t.div(class: "pl-2 border-l-2") { t << RenderGeneralLedgerTable.new(general_ledger_accounts) }
            end

            if customers
              t.strong("Customers")
              t.div(class: "pl-2 border-l-2 flex flex-wrap") {
                customers.each do |customer|
                  t << CompanyCard.new(customer)
                end
              }
            end

            if suppliers
              t.strong("Suppliers")
              t.div(class: "pl-2 border-l-2 flex flex-wrap") {
                suppliers.each do |supplier|
                  t << CompanyCard.new(supplier)
                end
              }
            end

            if tax_table
              t.strong("Tax table")
              t.div(class: "pl-2 border-l-2") { t << TaxTable.new(tax_table) }
            end

            if analysis_type_table
              t.strong("Analysis type table")
              t.div(class: "pl-2 border-l-2") { t << AnalysisTypeTable.new(analysis_type_table) }
            end

            if owners
              t.strong("Owners")
              t.div(class: "pl-2 border-l-2") { owners.each { |owner| t << owner } }
            end
          }
        end
      end

      refine(SAFT::V2::Types::Transaction) do
        def to_tubby
          Tubby.new { |t|
            t.div(
              id: "transaction-#{transaction_id}",
              class: "mb-2 pl-2 border-l-2 flex",
            ) {
              t.div(class: "w-80") {
                t
                  .a(
                    class: "whitespace-pre underline underline-offset-1 hover:underline-offset-2 visited:underline-decoration-2",
                    href: "#transaction-#{transaction_id}",
                  ) {
                    t.div {
                      t.strong("Transaction id ")
                      t << transaction_id
                    }
                  }
                t.div { t << RenderHash.new(attributes.except(:transaction_id, :lines)) }
              }
              t.div {
                t.strong("Lines ")
                t << LinesTable.new(lines)
              }
            }
          }
        end
      end
    end

    using DryStructRenderTubby

    class RenderHash
      def initialize(hash)
        @hash = hash.select { |_, value| value }
      end

      def to_tubby
        Tubby.new { |t|
          @hash.each do |key, value|
            t.div {
              t.strong("#{key.to_s.tr("_", " ").capitalize} ")
              t << value
            }
          end
        }
      end
    end

    class RenderGeneralLedgerTable
      def initialize(accounts)
        @accounts = accounts
      end

      def to_tubby
        Tubby.new { |t|
          t.table {
            t.thead {
              t.tr {
                t.th("Id")
                t.th("Description")
                t.th("Std account")
                t.th("Opening balance")
                t.th("Closing balance")
                t.th("Rest")
              }
            }
            t.tbody {
              @accounts.each do |account|
                std_account = SAFT::V2::Norway.std_account(account.standard_account_id)
                std_account_title = "Not found"
                if std_account
                  std_account_title = <<~TEXT
                    Account no #{std_account.number}
                    #{std_account.description_en}
                    #{std_account.description_no}
                  TEXT
                end

                t.tr {
                  t.td(account.account_id)
                  t.td(account.account_description)
                  t.td(account.standard_account_id, title: std_account_title)
                  t.td {
                    t.div(class: "flex justify-between") {
                      if account.opening_debit_balance
                        t.span("Debit")
                        t.span(account.opening_debit_balance)
                      end

                      if account.opening_credit_balance
                        t.span("Credit")
                        t.span(-account.opening_credit_balance)
                      end
                    }
                  }
                  t.td {
                    t.div(class: "flex justify-between") {
                      if account.closing_debit_balance
                        t.span("Debit")
                        t.span(account.closing_debit_balance)
                      end

                      if account.closing_credit_balance
                        t.span("Credit")
                        t.span(-account.closing_credit_balance)
                      end
                    }
                  }
                  t.td(class: "pl-2") {
                    t.div(class: "pl-2 border-l-2") {
                      t <<
                        RenderHash.new(
                          account
                            .attributes
                            .except(
                              :account_id,
                              :account_description,
                              :standard_account_id,
                              :opening_debit_balance,
                              :opening_credit_balance,
                              :closing_debit_balance,
                              :closing_credit_balance,
                            ),
                        )
                    }
                  }
                }
              end
            }
          }
        }
      end
    end

    class CompanyCard
      def initialize(company)
        @company = company
      end

      def to_tubby
        Tubby.new { |t|
          t.div(class: "min-w-[20rem] max-w-[20rem] mr-8 mb-2") {
            t.div(class: "pl-2 border-l-2") {
              t.span("Supplier", class: "font-semibold") if @company.is_a?(Types::Supplier)
              t.span("Customer", class: "font-semibold") if @company.is_a?(Types::Customer)
              t << RenderHash.new(@company.attributes)
            }
          }
        }
      end
    end

    class TaxTable
      def initialize(tax_table)
        @tax_table = tax_table
      end

      def to_tubby
        Tubby.new { |t|
          t.table {
            t.thead {
              t.tr {
                t.th("Tax code")
                t.th("Description")
                t.th("Country")
                t.th("Std code")
                t.th("Tax %", class: "text-right")
                t.th("Base rate", class: "text-right")
                t.th("rest")
              }
            }
            t.tbody {
              @tax_table.each { |table|
                table.tax_code_details.each { |detail|
                  vat_code = SAFT::V2::Norway.vat_code(detail.standard_tax_code)
                  vat_code_title = "Not found"
                  if vat_code
                    vat_code_title = <<~TEXT
                      Vat Code #{vat_code.code}
                      #{vat_code.description_en}
                      #{vat_code.description_no}
                      #{vat_code.tax_rate}
                      #{"Can be used for compensation" if vat_code.compensation}
                    TEXT
                  end

                  t.tr {
                    t.td(detail.tax_code)
                    t.td(detail.description)
                    t.td(detail.country)
                    t.td(detail.standard_tax_code, title: vat_code_title)
                    t.td(detail.tax_percentage, class: "text-right")
                    t.td(class: "text-right") { detail.base_rates.each { t.div(_1) } }
                    t.td(class: "pl-2") {
                      t.div(class: "pl-2 border-l-2") {
                        t <<
                          RenderHash.new(
                            detail
                              .attributes
                              .except(
                                :tax_code,
                                :description,
                                :country,
                                :standard_tax_code,
                                :base_rate,
                                :tax_percentage,
                              ),
                          )
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end
    end

    class AnalysisTypeTable
      def initialize(analysis_type_table)
        @analysis_type_table = analysis_type_table
      end

      def to_tubby
        Tubby.new { |t|
          t.table {
            t.thead {
              t.tr {
                t.th("Type")
                t.th("Type description")
                t.th("ID")
                t.th("ID Description")
                t.th("Rest")
              }
            }
            t.tbody {
              @analysis_type_table.each { |entry|
                html_analysis = t.get_analysis(entry.analysis_id, entry.analysis_type)
                t.tr(id: html_analysis.html_id) {
                  t.td(entry.analysis_type)
                  t.td(entry.analysis_type_description)
                  t.td(entry.analysis_id)
                  t.td(entry.analysis_id_description)
                  t.td(class: "pl-2") {
                    t.div(class: "pl-2 border-l-2") {
                      t <<
                        RenderHash.new(
                          entry
                            .attributes
                            .except(
                              :analysis_type,
                              :analysis_type_description,
                              :analysis_id,
                              :analysis_id_description,
                            ),
                        )
                    }
                  }
                }
              }
            }
          }
        }
      end
    end

    class LinesTable
      def initialize(lines)
        @lines = lines
      end

      def to_tubby
        Tubby.new { |t|
          t.table {
            t.thead {
              t.tr {
                t.th("RecordID")
                t.th("AccountID")
                t.th("Analysis")
                t.th("ValueDate")
                t.th("Description")
                t.th("Dedit Amount", class: "text-right")
                t.th("Credit Amount", class: "text-right")
                t.th("Rest")
              }
            }

            t.tbody {
              @lines.each { |line|
                t.tr {
                  t.td(line.record_id)
                  t.td {
                    account = t.get_account(line.account_id)
                    t.div(title: account.title) { t << line.account_id }
                  }

                  t.td {
                    line.analyses&.each do |line_analysis|
                      analysis = t.get_analysis(
                        line_analysis.analysis_id,
                        line_analysis.analysis_type,
                      )
                      t.div(title: analysis.title) { t << analysis.link { t << "#{line_analysis.analysis_type} #{line_analysis.analysis_id}" } }
                    end
                  }
                  t.td(line.value_date)
                  t.td(line.description)
                  t.td(line.debit_amount&.amount, class: "text-right")
                  t.td(line.credit_amount&.amount, class: "text-right")
                  t.td {
                    t.div(class: "mb-2 pl-2 border-l-2") {
                      if line.customer_id
                        customer = t.get_customer(line.customer_id)
                        t.div(title: customer.title) {
                          t.strong("Customer ")
                          t << line.customer_id
                          t << " #{customer.name}"
                        }
                      end

                      if line.supplier_id
                        supplier = t.get_supplier(line.supplier_id)
                        t.div(title: supplier.title) {
                          t.strong("Supplier ")
                          t << line.supplier_id
                          t << " #{supplier.name}"
                        }
                      end

                      t <<
                        RenderHash.new(
                          line
                            .attributes
                            .except(
                              :record_id,
                              :account_id,
                              :customer_id,
                              :supplier_id,
                              :analyses,
                              :value_date,
                              :description,
                              :debit_amount,
                              :credit_amount,
                            ),
                        )
                    }
                  }
                }
              }
            }
          }
        }
      end
    end

    class Analysis
      def initialize(analysis)
        @analysis = analysis
      end

      attr_reader :analysis

      def title
        <<~TEXT
          #{analysis.analysis_type}(#{analysis.analysis_type_description})
          #{analysis.analysis_id}(#{analysis.analysis_id_description})
        TEXT
      end

      def html_id
        "analysis-#{analysis.analysis_type}-#{analysis.analysis_id}"
      end

      def link
        Tubby.new { |t| t.a(href: "##{html_id}") { yield } }
      end
    end

    class NotFoundAnalysys
      include Singleton

      def title
        "Could not find analysis"
      end

      def link
        yield
        nil
      end
    end

    class Account
      attr_reader(:account)

      def initialize(account)
        @account = account
      end

      def title
        <<~TEXT
          #{account.account_id} #{account.account_description}
          Std account #{account.standard_account_id}
          opening balance #{HTML.format_big_decimal(account.opening_debit_balance || -account.opening_credit_balance)}
          closing balance #{HTML.format_big_decimal(account.closing_debit_balance || -account.closing_credit_balance)}
        TEXT
      end
    end

    class NotFoundAccount
      include(Singleton)

      def title
        "Could not find account"
      end
    end

    class Customer
      attr_reader(:customer)

      def initialize(customer)
        @customer = customer
      end

      def title
        <<~TEXT
          #{customer.name} #{customer.registration_number}
          opening balance #{HTML.format_big_decimal(customer.opening_debit_balance || -customer.opening_credit_balance)}
          closing balance #{HTML.format_big_decimal(customer.closing_debit_balance || -customer.closing_credit_balance)}
        TEXT
      end

      def name
        customer.name
      end
    end

    class NotFoundCustomer
      include(Singleton)

      def title
        "Could not find customer"
      end

      def name
        "Not found in Customers block"
      end
    end

    class Supplier
      attr_reader(:supplier)

      def initialize(supplier)
        @supplier = supplier
      end

      def title
        <<~TEXT
          #{supplier.name} #{supplier.registration_number}
          opening balance #{HTML.format_big_decimal(supplier.opening_debit_balance || -supplier.opening_credit_balance)}
          closing balance #{HTML.format_big_decimal(supplier.closing_debit_balance || -supplier.closing_credit_balance)}
        TEXT
      end

      def name
        supplier.name
      end
    end

    class NotFoundSupplier
      include(Singleton)

      def title
        "Could not find supplier"
      end

      def name
        "Not found in Suppliers block"
      end
    end

    class SaftRenderer < Tubby::Renderer
      def <<(obj)
        obj = obj.to_tubby if obj.respond_to?(:to_tubby)
        if obj.is_a?(Tubby::Template)
          obj.render_with(self)
        else
          @target << CGI.escape_html(obj.to_s)
        end

        self
      end

      def audit_file=(audit_file)
        (audit_file.master_files&.analysis_type_table || [])
          .each_with_object({}) { _2[[_1.analysis_id, _1.analysis_type]] = Analysis.new(_1) }
          .tap { @analysis_lookup = _1 }

        (audit_file.master_files&.customers || [])
          .each_with_object({}) { _2[_1.customer_id] = Customer.new(_1) }
          .tap { @customer_lookup = _1 }

        (audit_file.master_files&.suppliers || [])
          .each_with_object({}) { _2[_1.supplier_id] = Supplier.new(_1) }
          .tap { @supplier_lookup = _1 }

        (audit_file.master_files&.general_ledger_accounts || [])
          .each_with_object({}) { _2[_1.account_id] = Account.new(_1) }
          .tap { @account_lookup = _1 }
      end

      def get_analysis(id, type)
        @analysis_lookup.fetch([id, type]) { NotFoundAnalysys.instance }
      end

      def get_account(id)
        @account_lookup.fetch(id) { NotFoundAccount.instance }
      end

      def get_customer(id)
        @customer_lookup.fetch(id) { NotFoundCustomer.instance }
      end

      def get_supplier(id)
        @supplier_lookup.fetch(id) { NotFoundSupplier.instance }
      end

      def a(*args, **kwargs, &block)
        kwargs[:class] ||= ""
        kwargs[:class] += " whitespace-pre underline underline-offset-1 hover:underline-offset-2 visited:underline-decoration-2"
        super(*args, **kwargs, &block)
      end
    end

    def self.render(audit_file)
      target = +""
      renderer = SaftRenderer.new(target)
      renderer.audit_file = audit_file
      renderer << audit_file

      Tubby.new { |t| t.raw!(target) }
    end
  end
end
