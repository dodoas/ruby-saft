# frozen_string_literal: true

require "zeitwerk"
require "nokogiri"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("saft" => "SAFT")
loader.setup

module SAFT
  def self.nokogiri_save_setting= value
    @nokogiri_save_setting = value
  end

  def self.nokogiri_save_setting
    return @nokogiri_save_setting if defined?(@nokogiri_save_setting)

    @nokogiri_save_setting = Nokogiri::XML::Node::SaveOptions::AS_XML
  end
end
