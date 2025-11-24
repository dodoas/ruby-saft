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

  it "find grouping_code" do
    expect(described_class.grouping_category("1140"))
      .to be_instance_of(described_class::GroupingCategory)
    expect(described_class.grouping_category("1141")).to be(nil)
    expect(described_class.grouping_category("4003"))
      .to be_instance_of(described_class::GroupingCategory)
    expect(described_class.grouping_category("4400")).to be(nil)

    expect(described_class.grouping_category!("4007"))
      .to be_instance_of(described_class::GroupingCategory)
    expect { described_class.grouping_category!("4009") }
      .to raise_error(KeyError)
    expect(described_class.grouping_category!("5000"))
      .to be_instance_of(described_class::GroupingCategory)
    expect { described_class.grouping_category!("5001") }
      .to raise_error(KeyError)
  end

  it "include sample grouping_category" do
    expect(described_class.general_ledger_grouping_categories)
      .to(
        include(
          have_attributes(
            grouping_category: "varekostnad",
            category_description_no: "Næringsspesifikasjon",
            category_description_en: "Income Statement",
            grouping_code: "4004",
            code_description_no: "Handling fee / Service fee / Trading fee",
            code_description_en: "Handling fee / Service fee / Trading fee",
          ),
        ),
      )
  end
end
