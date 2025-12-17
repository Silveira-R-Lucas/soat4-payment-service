# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Soat4PaymentService
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.autoload_paths += %W[
      #{config.root}/app/domain
      #{config.root}/app/domain/ports
      #{config.root}/app/domain/product
      #{config.root}/app/domain/client
      #{config.root}/app/domain/cart
      #{config.root}/app/domain/payment
      #{config.root}/app/domain/use_cases
      #{config.root}/app/domain/use_cases/product
      #{config.root}/app/domain/use_cases/client
      #{config.root}/app/domain/use_cases/cart
      #{config.root}/app/domain/use_cases/payment
      #{config.root}/app/infrastructure
      #{config.root}/app/infrastructure/persistence
      #{config.root}/app/infrastructure/external_apis
      #{config.root}/app/infrastructure/external_apis/mercado_pago
      #{config.root}/app/infrastructure/persistence/active_record
      #{config.root}/app/infrastructure/persistence/active_record/products
      #{config.root}/app/infrastructure/persistence/active_record/clients
      #{config.root}/app/infrastructure/persistence/active_record/carts
      #{config.root}/app/infrastructure/persistence/mongo
      #{config.root}/app/infrastructure/messaging
      #{config.root}/app/infrastructure/workers
    ]

    config.hosts << 'pagamento-service'
    config.hosts << /.*\.ngrok-free\.dev/
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
