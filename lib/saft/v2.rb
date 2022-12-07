# frozen_string_literal: true

require "nokogiri"
require "dry-struct"

module SAFT::V2
  def self.parse(xml_content)
    doc = Nokogiri::XML(xml_content)
    doc.remove_namespaces!
    Parse.call(doc).then { Types::AuditFile.call(_1) }
  end

  def self.scribe(audit_file)
    raise ArgumentError unless audit_file.is_a?(Types::AuditFile)

    Scribe.write_xml(audit_file)
  end

  def self.validate(xml_content)
    XsdValidate.new(xml_content)
  end

  def self.to_html(audit_file)
    raise ArgumentError unless audit_file.is_a?(Types::AuditFile)

    HTML.render(audit_file)
  end
end
