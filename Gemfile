source "https://rubygems.org"

ruby "3.3.3"

gem "puma", ">= 5.0"
gem "rails", "~> 7.1.3", ">= 7.1.3.4"

gem "sqlite3", "~> 1.4"

gem "importmap-rails"
gem "propshaft"

gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]

  gem "rspec", "~> 3.10"
  gem "standard"
end

group :development do
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

