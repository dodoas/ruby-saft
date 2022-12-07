# frozen_string_literal: true

require_relative "lib/saft/version"

Gem::Specification.new do |spec|
  spec.name = "saft"
  spec.version = SAFT::VERSION
  spec.summary = "SAF-T parser and writer"
  spec.authors = ["Dodo developer", "Simon Toivo Telhaug"]
  spec.email = ["simon.toivo.telhaug@dev.dodo.no"]
  # spec.homepage = "http://tba.no"

  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"
  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git))})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("zeitwerk", "~> 2.5")
  spec.add_dependency("dry-struct", "~> 1.4")
  spec.add_dependency("nokogiri", "~> 1.13")
end
