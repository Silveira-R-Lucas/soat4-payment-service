require 'rails_helper'

RSpec.describe "Api::V1::MpWebhook", type: :request do
  let(:process_service) { instance_double(ProcessMercadopagoNotification) }

  before do
    allow(ProcessMercadopagoNotification).to receive(:new).and_return(process_service)
  end

  describe "POST /api/v1/payment_notification" do
    it "retorna 200 se processado com sucesso" do
      allow(process_service).to receive(:call).and_return(true)
      
      post "/api/v1/payment_notification", params: { type: "payment" }
      expect(response).to have_http_status(:ok)
    end

    it "retorna 422 se o processamento falhar (ex: assinatura inválida)" do
      allow(process_service).to receive(:call).and_return(false)
      
      post "/api/v1/payment_notification", params: {}
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "retorna 400 em caso de ArgumentError" do
      allow(process_service).to receive(:call).and_raise(ArgumentError.new("Pedido não encontrado"))
      
      post "/api/v1/payment_notification"
      expect(response).to have_http_status(:bad_request)
    end

    it "retorna 500 em erro inesperado" do
      allow(process_service).to receive(:call).and_raise(StandardError.new("Boom"))
      
      post "/api/v1/payment_notification"
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end