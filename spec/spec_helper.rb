# frozen_string_literal: true

require "saft"

Dir[Pathname.new(__dir__).join("support/**/*.rb")].sort.each { |f| require f }

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.filter_run_when_matching(:focus)
  config.run_all_when_everything_filtered = true

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.warnings = true

  config.expect_with(:rspec) do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand(config.seed)
end

SAFT.nokogiri_save_setting = Nokogiri::XML::Node::SaveOptions::DEFAULT_XML
