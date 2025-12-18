# frozen_string_literal: true

require_relative 'boot'

require "rails/all"

Bundler.require(*Rails.groups)

module Soat4PaymentService
  class Application < Rails::Application
    config.load_defaults 7.0

    config.hosts << 'pagamento-service'
    config.hosts << /.*\.ngrok-free\.dev/

    config.api_only = true
  end
end
