# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessMercadopagoNotification do
  let(:webhook_adapter) { instance_double(MercadopagoWebhookAdapter) }
  let(:repository) { instance_double(MongoPaymentRepository) }
  let(:publisher) { instance_double(RabbitmqPublisher) }
  let(:payment_domain) { build(:payment, items: []) }

  subject { described_class.new(mercadopago_webhook_adapter: webhook_adapter, payment_repository: repository) }

  before do
    allow(RabbitmqPublisher).to receive(:new).and_return(publisher)
    allow(UpdatePayment).to receive(:new).and_return(instance_double(UpdatePayment, call: true))
  end

  describe '#call' do
    let(:params) { { 'type' => 'payment' } }
    let(:headers) { {} }
    let(:payment_id) { '12345' }

    context 'quando a notificação é válida e aprovada' do
      let(:api_details) do
        {
          successful: true,
          details: {
            id: payment_id,
            status: 'approved',
            transaction_amount: 50.0,
            external_reference: 'pedido_1',
            payment_method_id: 'pix'
          }
        }
      end

      before do
        allow(webhook_adapter).to receive(:parse_notification).and_return(payment_id)
        allow(webhook_adapter).to receive(:get_payment_details).with(payment_id).and_return(api_details)
        allow(repository).to receive(:find_by_pedido_id).with('pedido_1').and_return(payment_domain)
      end

      it 'publica evento PagamentoAprovado' do
        expect(publisher).to receive(:publish).with('PagamentoAprovado', hash_including(status: 'approved'))

        result = subject.call(params: params, headers: headers)
        expect(result).to be true
      end
    end

    context 'quando o pagamento é negado' do
      let(:api_details) do
        {
          successful: true,
          details: {
            id: payment_id,
            status: 'rejected',
            external_reference: 'pedido_1',
            payment_method_id: 'credit_card'
          }
        }
      end

      before do
        allow(webhook_adapter).to receive(:parse_notification).and_return(payment_id)
        allow(webhook_adapter).to receive(:get_payment_details).with(payment_id).and_return(api_details)
        allow(repository).to receive(:find_by_pedido_id).with('pedido_1').and_return(payment_domain)
      end

      it 'publica evento PagamentoNegado' do
        expect(publisher).to receive(:publish).with('PagamentoNegado', hash_including(status: 'rejected'))

        result = subject.call(params: params, headers: headers)
        expect(result).to be false # O retorno do método é false para "não aprovado" conforme implementação
      end
    end

    context 'falhas' do
      it 'retorna false se a assinatura do webhook for inválida' do
        allow(webhook_adapter).to receive(:parse_notification).and_return(nil)
        expect(subject.call(params: params, headers: headers)).to be false
      end

      it 'loga erro se a chamada da API de detalhes falhar' do
        allow(webhook_adapter).to receive(:parse_notification).and_return(payment_id)
        allow(webhook_adapter).to receive(:get_payment_details).and_return({ successful: false, error: 'Erro' })

        expect(Rails.logger).to receive(:error).with(/Falha ao pegar detalhes/)
        expect(subject.call(params: params, headers: headers)).to be false
      end
    end
  end
end
