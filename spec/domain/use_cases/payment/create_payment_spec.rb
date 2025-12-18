# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreatePayment do
  let(:repository) { instance_double(MongoPaymentRepository) }
  let(:gateway) { instance_double(MercadopagoPaymentGatewayAdapter) }
  subject { described_class.new(payment_repository: repository, payment_gateway: gateway) }

  describe '#execute' do
    let(:pedido_id) { '123' }
    let(:amount) { 100.0 }
    let(:items) { [] }
    let(:gateway_response) do
      {
        successful: true,
        response: { 'in_store_order_id' => 'mp_123', 'qr_data' => 'qr_code_sample' }
      }
    end

    it 'gera QR Code no gateway e salva o pagamento' do
      expect(gateway).to receive(:generate_qr_payment).with(pedido_id, amount, items).and_return(gateway_response)
      expect(repository).to receive(:save).with(an_instance_of(Payment))

      result = subject.execute(pedido_id, amount, items)

      expect(result[:successful]).to be true
      expect(result[:payment_details]).to eq('qr_code_sample')
      expect(result[:pedido_id]).to eq(pedido_id)
    end

    it 'retorna erro se o gateway falhar' do
      allow(gateway).to receive(:generate_qr_payment).and_raise(StandardError.new('API Error'))

      result = subject.execute(pedido_id, amount, items)

      expect(result[:successful]).to be false
      expect(result[:error]).to eq('API Error')
    end
  end
end
