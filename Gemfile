source 'https://rubygems.org'

gem 'rails', '4.1.6'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'annotate', '~> 2.6.2' # Auto comments with fields of models
gem 'faraday'
gem 'nokogiri'
gem 'procto'
gem 'unicorn'

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
  gem 'rubocop'
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
