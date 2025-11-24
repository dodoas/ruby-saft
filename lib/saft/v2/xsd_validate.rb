# frozen_string_literal: true

require "nokogiri"
require "pathname"

XSD_PATH = Pathname.new(__dir__) + ".." + ".." + ".." + "vendor" + "Norwegian_SAF-T_Financial_Schema_v_1.30.xsd"

module SAFT::V2
  class XsdValidate
    def initialize(content)
      @xml_errors = []
      doc = Nokogiri::XML(content)
      @xml_errors.push(*doc.errors)
      xsd = Nokogiri::XML::Schema(XSD_PATH)
      @xml_errors.push(*xsd.validate(doc))
      # All error are of type Nokogiri::XML::SyntaxError
      # https://nokogiri.org/rdoc/Nokogiri/XML/SyntaxError.html
    end

    def valid? = @xml_errors.none?
    def invalid? = !valid?

    def errors = @xml_errors
  end
end
