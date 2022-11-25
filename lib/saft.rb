# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("saft" => "SAFT")
loader.setup

module SAFT
end
