source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby
# Gema de los permisos
gem 'cancancan', '~> 2.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
#Gema para generar los gráficos
gem "chartkick"
gem 'groupdate'

# GENA código de barras
gem 'barby', '~> 0.6.6'
gem 'chunky_png'

gem 'rb-readline'

#gem 'byebug'
#GEMA WYSIWYG
gem 'summernote-rails', '~> 0.8.10.0'

#GEMA DE WICKED PDFKit
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

#Validaciones
gem 'jquery-validation-rails'
# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

#Boostrap
gem 'bootstrap', '~> 4.3.1'
gem 'bootstrap-toggle-rails'

gem 'alertifyjs-rails'

#Fontawesome
gem 'font-awesome-sass', '~> 5.3.1'

#Carrierwave
gem 'aws-sdk', '~> 2'

#Librerias de AFIP - wsfe - wspsr - wsctg
gem 'Afip'

# Paginación
gem 'will_paginate', '~> 3.1.1'
gem 'will_paginate-bootstrap4'

gem 'devise'

gem 'devise-i18n-views'

#Nested forms
gem "nested_form"

#JQuery
gem 'jquery-rails'
gem 'jquery-ui-rails'

#Autocomplete
gem 'rails-jquery-autocomplete'

#Datepicker
gem 'bootstrap-datepicker-rails'#, :require => 'bootstrap-datepicker-rails', :git => 'git://github.com/Nerian/bootstrap-datepicker-rails.git'

#Workers
gem 'delayed_job_active_record'

#Push notifications
gem 'private_pub'

#Consultas automaticas en AJAX
gem 'pjax_rails'

#Importar en una sola consulta a la DB
gem 'activerecord-import'

gem 'pry-rails'

# Gema para logs
gem 'rollbar'
#Gemas para importar o trabajar con excel
gem 'roo'
gem 'roo-xls'
gem 'rubyzip', '>= 1.2.1'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'
gem 'zip-zip'

gem 'numbers_and_words'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
  gem 'guard-rspec'
  gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'master'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  #gem 'rb-readline'
  #Performance
  gem 'ruby-prof'
  gem 'thin'
  gem "letter_opener"
  gem "churn"
  gem 'capistrano3-delayed-job'
  gem 'capistrano'
  gem 'capistrano-rbenv'
  gem 'capistrano-rbenv-install'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-unicorn-nginx'
  gem 'capistrano-postgresql'
  gem 'capistrano-safe-deploy-to'
  gem 'capistrano-ssh-doctor', git: 'https://github.com/capistrano-plugins/capistrano-ssh-doctor.git'
  gem 'capistrano-linked-files'
  gem 'capistrano-rails-console', require: false
  gem 'capistrano-logger'
  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf'
end

group :production do
  # Use Puma as the app server
  gem 'puma', '~> 3.11'
  gem 'rails_12factor'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "unicorn"
gem 'daemons'
