# frozen_string_literal: true

class RabbitmqPublisher
  require 'json'

  def initialize(exchange_name)
    @channel = RabbitmqConnection.channel
    @exchange = @channel.fanout(exchange_name, durable: true)
  end

  def publish(event_name, payload)
    message = { event: event_name, payload: payload, timestamp: Time.now }.to_json
    @exchange.publish(message)
    Rails.logger.info("📤 Published event: #{event_name}")
  end
end
