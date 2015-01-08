source 'https://rubygems.org'

gem 'rails', '~> 4.1.6'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'rake'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'activeadmin', github: 'activeadmin'
gem 'annotate', '~> 2.6.2' # Auto comments with fields of models
gem 'coderay'
gem 'envied'
gem 'faraday'
gem 'github_api'
gem 'httpclient'
gem 'kaminari'
gem 'newrelic_rpm'
gem 'nokogiri'
gem 'nprogress-rails'
gem 'procto'
gem 'rack-attack'
gem 'rollbar', '~> 1.1.0'
gem 'rubocop'
gem 'rubyzip', '>= 1.0.0'
gem 'sidekiq'
gem 'sidetiq'
gem 'sinatra', '>= 1.3.3', require: nil # Required for sidekiq-webinterface
gem 'unicorn'
gem 'virtus'

gem 'foreman'

group :production do
  # Needed for heroku
  # https://github.com/heroku/rails_12factor
  gem 'rails_12factor'
end

group :test, :development do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '>= 4.1'
  gem 'ffaker'
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'vcr'

  # Metrics
  gem 'brakeman', '>= 2.6.0'
  gem 'flog'
  gem 'rails_best_practices'
end

group :test do
  gem 'webmock'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets' # Suppress asset pipeline calls in logs
  gem 'spring'
  gem 'thin'
  gem 'yard', github: 'lsegal/yard'
end
