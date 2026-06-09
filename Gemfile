source 'https://rubygems.org'
git_source(:github) { |repo| 'https://github.com/#{repo}.git' }

ruby '3.4.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 7.2'
# The asset pipeline for Rails
gem 'sprockets-rails'
# Bundle and transpile JavaScript with esbuild
gem 'jsbundling-rails'
# Bundle and process CSS with Sass
gem 'cssbundling-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1', '>= 3.1.13'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.5', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :windows]
  # A Ruby gem to load environment variables from `.env`.
  gem 'dotenv-rails'
  # Code coverage
  gem 'simplecov', require: false
  # Ruby 3.4 no longer ships drb by default; Rails parallel tests still need it
  gem 'drb'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.0'
  gem 'listen', '~> 3.1', '>= 3.1.5'
  # Process manager for Procfile-based applications
  gem 'foreman'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:windows, :jruby]

# Auth via GH
gem 'omniauth-github'
gem 'omniauth', '~> 2.1'
gem 'omniauth-rails_csrf_protection'

# Markdown for posts
gem 'redcarpet', '~> 3.5'

# Background jobs
gem 'delayed_job', '~> 4.1', '>= 4.1.8'
gem 'delayed_job_active_record'

# Error tracking
gem 'rollbar'

# # Heroku Ruby Metrics
# gem 'barnes'

# https://stackoverflow.com/questions/71851775/rails-6-1-5-uninitialized-constant-mailtestmailer
gem 'net-smtp' # to send email
gem 'net-imap' # for rspec
gem 'net-pop'  # for rspec

# Try removing later, not sure if needed, some warning
gem 'mutex_m'

# Mistral AI for description and title generation
gem 'omniai-mistral'