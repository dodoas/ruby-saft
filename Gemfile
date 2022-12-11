# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

gem "rake", "~> 13.0"
gem "tubby"

group :test do
  gem "rspec", "~> 3.12"
  gem "deep_compact", "~> 0.1.0"
end

group :development, :test do
  gem "standard", "~> 1.18"

  gem "rubocop", "~> 1.39"
  gem "rubocop-performance", "~> 1.15"
  gem "rubocop-rake", "~> 0.6.0"
  gem "rubocop-rspec", "~> 2.15"

  gem "dead_end", "~> 4.0"
end
