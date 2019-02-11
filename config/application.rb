require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Facturacion
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.cache_store                   = [ :file_store, "/tmp/rails-cache/" ]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    #Traduccion al español
  	config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
  	config.i18n.default_locale = :es

    config.after_initialize do
      Devise::SessionsController.skip_before_action   :redirect_to_company
      Devise::PasswordsController.skip_before_action  :redirect_to_company
      Devise::UnlocksController.skip_before_action    :redirect_to_company
      Devise::RegistrationsController.skip_before_action :redirect_to_company
      Devise::ConfirmationsController.skip_before_action :redirect_to_company
    end
  end
end
require 'Afip'
