# frozen_string_literal: true

require "zeitwerk"
require "nokogiri"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("saft" => "SAFT", "html" => "HTML")
loader.setup

loader.do_not_eager_load("#{__dir__}/saft/v2/html.rb")

module SAFT
  def self.gem_root
    Pathname(__dir__).parent
  end

  def self.nokogiri_save_setting=(value)
    @nokogiri_save_setting = value
  end

  def self.nokogiri_save_setting
    return @nokogiri_save_setting if defined?(@nokogiri_save_setting)

    @nokogiri_save_setting = Nokogiri::XML::Node::SaveOptions::AS_XML
  end
end
