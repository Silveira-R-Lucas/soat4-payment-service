class StartPagamentoConsumer
  def self.run
    RabbitmqConsumer.new('carrinho.events', 'payment-service.carrinho-finalizado').start_listening
  end
end