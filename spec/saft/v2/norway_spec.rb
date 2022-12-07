# frozen_string_literal: true

RSpec.describe SAFT::V2::Norway do
  it "include sample vat categories" do
    expect(described_class.vat_codes)
      .to(
        include(
          have_attributes(
            code: "21",
            description_no: "Kostnad ved innførsel av varer",
            description_en: "Basis on import of goods",
            tax_rate: "Regular rate",
            compensation: true,
          ),
        ),
      )
  end

  it "find vat code" do
    expect(described_class.vat_code("21"))
      .to be_instance_of(described_class::VatTaxCode)
    expect(described_class.vat_code("21221")).to be(nil)

    expect(described_class.vat_code!("21"))
      .to be_instance_of(described_class::VatTaxCode)
    expect { described_class.vat_code!("21221") }
      .to raise_error(KeyError)
  end

  it "find std account" do
    expect(described_class.std_account("43"))
      .to be_instance_of(described_class::Account)
    expect(described_class.std_account("44")).to be(nil)
    expect(described_class.std_account("4390"))
      .to be_instance_of(described_class::Account)
    expect(described_class.std_account("4400")).to be(nil)

    expect(described_class.std_account!("43"))
      .to be_instance_of(described_class::Account)
    expect { described_class.std_account!("44") }
      .to raise_error(KeyError)
    expect(described_class.std_account!("4390"))
      .to be_instance_of(described_class::Account)
    expect { described_class.std_account!("4400") }
      .to raise_error(KeyError)
  end

  it "include sample account plan with 2 digits" do
    expect(described_class.general_ledger_accounts_2_digits)
      .to(
        include(
          have_attributes(
            number: "11",
            description_no: "Tomter, bygninger og annen fast eiendom",
            description_en: "Land, buildings and other real property",
          ),
        ),
      )
  end

  it "include sample account plan with 4 digits" do
    expect(described_class.general_ledger_accounts_4_digits)
      .to(
        include(
          have_attributes(
            number: "1145",
            description_no: "Skogbrukseiendommer",
            description_en: "Forestry property",
          ),
        ),
      )
  end
end
