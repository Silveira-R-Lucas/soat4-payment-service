require 'rails_helper'

RSpec.describe MercadopagoPaymentGatewayAdapter do
  subject { described_class.new }
  let(:curl_mock) { instance_double(Curl::Easy) }

  before do
    allow(Curl).to receive(:post).and_yield(curl_mock).and_return(curl_mock)
    allow(curl_mock).to receive(:headers).and_return({})
    allow(curl_mock).to receive(:body).and_return('{"in_store_order_id": "123", "qr_data": "qr"}')
    allow(curl_mock).to receive(:code).and_return(201) 
  end

  describe '#generate_qr_payment' do
    it 'gera o QR Code com sucesso (201)' do
      allow(curl_mock).to receive(:code).and_return(201)
      
      result = subject.generate_qr_payment("pedido_1", 100.0, [])
      
      expect(result[:successful]).to be true
      expect(result[:status]).to eq(201)
      expect(result[:response]["qr_data"]).to eq("qr")
    end

    it 'retorna erro se a API falhar (400)' do
      allow(curl_mock).to receive(:code).and_return(400)
      allow(curl_mock).to receive(:body).and_return('{"error": "bad_request"}')
      
      result = subject.generate_qr_payment("pedido_1", 100.0, [])
      
      expect(result[:successful]).to be false
      expect(result[:status]).to eq(400)
    end
  end
end