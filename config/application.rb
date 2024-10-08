# frozen_string_literal: true
require_relative 'boot'
require 'rails/all'
require 'csv'
require 'retriable'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PeakDemandAlerts
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone = 'Eastern Time (US & Canada)'
    config.action_mailer.asset_host = 'https://peak-alerts.herokuapp.com'
    config.generators.javascript_engine = :js
  end
end
