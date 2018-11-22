# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

my_date_formats = { :default => '%d/%m/%Y' } 

Date::DATE_FORMATS.merge!(my_date_formats)
