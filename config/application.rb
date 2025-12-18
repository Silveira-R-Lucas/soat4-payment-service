# frozen_string_literal: true

require_relative 'boot'

require "rails/all"

Bundler.require(*Rails.groups)

module Soat4PaymentService
  class Application < Rails::Application
    config.load_defaults 7.0

    config.hosts << 'pagamento-service'
    config.hosts << /.*\.ngrok-free\.dev/

    config.autoload_paths << Rails.root.join('app/domain')

    config.autoload_paths += %W[
      #{config.root}/app/domain/payment
      #{config.root}/app/domain/ports
      #{config.root}/app/domain/use_cases/payment
      #{config.root}/app/infrastructure/persistence/mongo
      #{config.root}/app/infrastructure/external_apis/mercado_pago
      #{config.root}/app/infrastructure/messaging
    ]
    
    # Remove dependências explícitas que causam conflito
    config.add_autoload_paths_to_load_path = false
    config.api_only = true
  end
end
