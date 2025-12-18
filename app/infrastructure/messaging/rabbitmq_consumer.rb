# frozen_string_literal: true

class RabbitmqConsumer
  require 'json'

  def initialize(exchange_name, queue_name, handlers = {})
    @channel = RabbitmqConnection.channel
    @exchange = @channel.fanout(exchange_name, durable: true)
    @queue = @channel.queue(queue_name, durable: true)
    @queue.bind(@exchange)
    @handlers = handlers
  end

  # :nocov:
  def start_listening
    Rails.logger.info("🎧 Listening to #{@queue.name}")
    @queue.subscribe(block: true, manual_ack: true) do |delivery_info, _properties, payload|
      handle_message(payload)
      @channel.ack(delivery_info.delivery_tag)
    end
  rescue Interrupt
    @channel.close
    RabbitmqConnection.instance.close
  end

  private
  # :nocov:

  def handle_message(payload)
    data = JSON.parse(payload)
    event = data['event']
    payload_data = data['payload']
    @handlers[event]

    if event == 'CarrinhoFinalizado'
      Rails.logger.info("✅ Handled event: #{event}")
      puts "💳 Criando pagamento do pedido #{payload_data['pedido_id']}"
      puts "payload_data: #{payload_data}"
      repository = MongoPaymentRepository.new
      gateway = MercadopagoPaymentGatewayAdapter.new
      response = CreatePayment.new(payment_repository: repository, payment_gateway: gateway)
                              .execute(
                                payload_data['pedido_id'].to_s,
                                payload_data['total_amount'],
                                payload_data['items']
                              )
      puts "response: #{response}"
      publisher = RabbitmqPublisher.new('pagamento.events')
      publisher.publish('PagamentoCriado', response)
    else
      Rails.logger.warn("⚠️ No handler for event: #{event}")
    end
  rescue StandardError => e
    Rails.logger.error("❌ Error handling message: #{e.message}")
  end
end
