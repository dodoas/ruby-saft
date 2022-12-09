# frozen_string_literal: true

RSpec.describe SAFT::V2::Types do
  it "has strict mode for PersonNameStructure" do
    type = described_class::Strict::PersonNameStructure
    expect(type[first_name: "Joe", last_name: "Doe"])
      .to(
        be_instance_of(described_class::Strict::PersonNameStructure)
          .and(have_attributes(first_name: "Joe", last_name: "Doe")),
      )

    expect { type[first_name: "J" * 36, last_name: "Doe"] }.to(raise_error(Dry::Struct::Error))
  end

  it "has relaxed mode for PersonNameStructure" do
    type = described_class::Relaxed::PersonNameStructure
    expect(type[first_name: "Joe", last_name: "Doe"])
      .to(
        be_instance_of(described_class::Relaxed::PersonNameStructure)
          .and(have_attributes(first_name: "Joe", last_name: "Doe")),
      )

    expect(type[first_name: "J" * 36, last_name: "Doe"])
      .to(
        be_instance_of(described_class::Relaxed::PersonNameStructure)
          .and(have_attributes(first_name: "J" * 36, last_name: "Doe")),
      )
  end

  it "has sliced mode for PersonNameStructure" do
    type = described_class::Sliced::PersonNameStructure
    expect(type[first_name: "Joe", last_name: "Doe"])
      .to(
        be_instance_of(described_class::Sliced::PersonNameStructure)
          .and(have_attributes(first_name: "Joe", last_name: "Doe")),
      )

    expect(type[first_name: "J" * 36, last_name: "Doe"])
      .to(
        be_instance_of(described_class::Sliced::PersonNameStructure)
          .and(have_attributes(first_name: "J" * 35, last_name: "Doe")),
      )
  end
end
