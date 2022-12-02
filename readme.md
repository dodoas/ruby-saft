# SAF-T (Standard Audit File for Tax)

SAF-T is developed by OECD (Organisation for Economic Co-operation and Development). v1.0 was shiped in 2005, v2.0 was shiped in 2010. 

https://en.wikipedia.org/wiki/SAF-T

In norway we use version v2.0 of the format but Skatteetaten in norway has make some modifications and released there own versioning starting on v1.0 but that was a continuation on v2.0. I believe the only changes are related to which nodes should be used for what, so 100% backward compatible for SAF-T v2.0.

This gem is developed to work in Norway but it should be possible to make it work for all SAF-T versions. We didn't implement all Nodes but it should be quite easy to add. 

Tested and verified for: None jet, Norway is in development

Even if you are able to create a AuditFile instance it doen't mean it is valid per xsd. There are some nodes where you have to choose this set of nodes or this other set of nodes. It would be possible to create such a structure it dry-stuct as well but we would end up with a lot more Nodes, also a bigger difference on xml structure and structs. 

## Setup

```rb
# if you use SAF-T to write xmls you probably want the files to be as compact as
# possible in production but nicely formatted in development end test.
# default value is AS_XML

if production
  SAFT.nokogiri_save_setting = Nokogiri::XML::Node::SaveOptions::AS_XML
else
  SAFT.nokogiri_save_setting = Nokogiri::XML::Node::SaveOptions::DEFAULT_XML
end
```

## Usage

```rb
require "saft"

# read a SAF-T file

xml = File.read("saft.xml")
audit_file = SAFT::V2.parse(xml) # instance of SAFT::V2::Types::AuditFile or raises type errors
audit_file.header.company.name #  name from xml

# create a SAF-T file
audit_file = SAFT::V2::Types::AuditFile.call({
  header: {
    audit_file_version: "1.10",
    audit_file_country: "NO",
    audit_file_date_created: Date.today,
    # ...
  }
})

xml_content = SAFT::V2.scribe(audit_file)
# it is recommended to validate agains the xsd before taking it further because 
# it is possible to create invalid xml
validations = SAFT::V2.validate(xml_content)
validations.valid? # true || false
validations.errors? # [] # array of Nokogiri::XML::SyntaxError from xsd errors


```

## Norway 

Main site for skatteetaten https://www.skatteetaten.no/en/business-and-organisation/start-and-run/best-practices-accounting-and-cash-register-systems/saf-t-financial/documentation/

Git repo with from government https://github.com/Skatteetaten/saf-t

SAF-T contains two formats, SAF-T Financial and SAF-T Cash Register. 

Every electronic ERP system has to implement SAF-T Financial. SAF-T Cash
Register is either for the cash regisert to implment or the ERP, I don't know
yet. (I believe Cash Register since there should be event log which include
open drawer, copy receipt, etc)
