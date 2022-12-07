# frozen_string_literal: true

# intended to be included in spec files to help with loading fixture data
# should only be used in specs, not in factories
# keep it small, don't pollute the method namespace in tests too much
module FixtureHelper
  # define the fixture path as a constant outside of RSpec
  # so it can be retrieved without RSpec being loaded
  FIXTURE_PATH = Pathname(__dir__).parent + "fixtures"

  def fixture_read(partial_path)
    File.read(FIXTURE_PATH.join(partial_path))
  end
end
