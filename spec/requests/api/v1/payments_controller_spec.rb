require 'rails_helper'

RSpec.describe "Api::V1::Payments", type: :request do
  let(:create_use_case) { instance_double(CreatePayment) }
  
  before do
    allow(CreatePayment).to receive(:new).and_return(create_use_case)
  end

  describe "POST /api/v1/pagamentos" do
    let(:params) do
        { payment: { pedido_id: "123", total_amount: 100.0, items: [] } }
    end

    context "sucesso" do
      before do
        allow(create_use_case).to receive(:execute).and_return({ successful: true, payment_details: "qr_data" })
      end

      it "retorna 201 Created" do
        post "/api/v1/pagamentos", params: params
        expect(response).to have_http_status(:created)
      end
    end

    context "erro" do
      before do
        allow(create_use_case).to receive(:execute).and_raise(StandardError.new("Erro"))
      end

      it "retorna 422 Unprocessable Entity" do
        post "/api/v1/pagamentos", params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /api/v1/pagamentos/:id/status" do
    let(:payment) { build(:payment, payment_id: "MP_123", pedido_id: "PED_1", amount: 50.0) }
    let(:repository_mock) { instance_double(MongoPaymentRepository) }

    before do
      allow(MongoPaymentRepository).to receive(:new).and_return(repository_mock)
      allow(repository_mock).to receive(:find_by_pedido_id).with("PED_1").and_return(payment)
    end
    it "retorna status 200" do
      get "/api/v1/pagamentos/#{payment.pedido_id}/status"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['successful']).to be true
    end
  end
end