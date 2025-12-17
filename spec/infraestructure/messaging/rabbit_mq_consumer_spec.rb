# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RabbitmqConsumer do
  let(:channel) { double('Channel', fanout: double, queue: double(bind: true, subscribe: true), ack: true) }
  let(:create_payment) { instance_double(CreatePayment) }
  let(:publisher) { instance_double(RabbitmqPublisher) }

  before do
    allow(RabbitmqConnection).to receive(:channel).and_return(channel)
    allow(CreatePayment).to receive(:new).and_return(create_payment)
    allow(RabbitmqPublisher).to receive(:new).and_return(publisher)
  end

  describe '#handle_message (via send)' do
    let(:consumer) { described_class.new('exchange', 'queue') }
    let(:payload) do
      {
        event: 'CarrinhoFinalizado',
        payload: { 'pedido_id' => 1, 'total_amount' => 50.0, 'items' => [] }
      }.to_json
    end

    it 'cria o pagamento e publica o evento PagamentoCriado' do
      expect(create_payment).to receive(:execute).with('1', 50.0, []).and_return({ some: 'data' })
      expect(publisher).to receive(:publish).with('PagamentoCriado', { some: 'data' })

      consumer.send(:handle_message, payload)
    end

    it 'ignora eventos desconhecidos' do
      unknown_payload = { event: 'EventoDesconhecido', payload: {} }.to_json
      expect(Rails.logger).to receive(:warn).with(/No handler for event/)

      consumer.send(:handle_message, unknown_payload)
    end
  end
end
