# frozen_string_literal: true

RabbitmqConsumer.new('carrinho.events', 'payment-service.carrinho-finalizado').start_listening
