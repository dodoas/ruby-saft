# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new do |t|
  config_file = File.join(File.dirname(__FILE__), ".rubocop.yml")

  t.options = ["-c", config_file]
  t.options << "-a" if ARGV.include?("-a")
  t.options << "-A" if ARGV.include?("-A")
end

task default: %i[spec rubocop]
