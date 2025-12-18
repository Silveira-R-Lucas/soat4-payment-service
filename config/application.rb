# frozen_string_literal: true

require_relative 'boot'

require "rails/all"

Bundler.require(*Rails.groups)

module Soat4PaymentService
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
    
    config.autoload_paths += %W[
      #{config.root}/app/domain/use_cases/payment
      #{config.root}/app/domain/payment
      #{config.root}/app/infrastructure/persistence/mongo
      #{config.root}/app/infrastructure/external_apis/mercado_pago
      #{config.root}/app/infrastructure/messaging
    ]

    Rails.autoloaders.main.ignore(Rails.root.join('app/domain/use_cases'))
    Rails.autoloaders.main.ignore(Rails.root.join('app/infrastructure')) 
    
    config.autoload_paths << Rails.root.join('app/domain')
  end
end
