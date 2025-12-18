# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MercadopagoWebhookAdapter do
  subject { described_class.new }
  let(:curl_mock) { instance_double(Curl::Easy) }

  describe '#parse_notification' do
    let(:params) { { 'data' => { 'id' => '12345' }, 'type' => 'payment', 'data.id' => '12345' } }
    let(:headers) do
      {
        'HTTP_X_REQUEST_ID' => 'req-1',
        'HTTP_X_SIGNATURE' => 'ts=123456,v1=assinatura_invalida'
      }
    end

    it 'retorna o ID se a assinatura for válida (mockando a verificação)' do
      # Mockamos o método privado ou a lógica de hash para simplificar,
      # ou passamos uma assinatura válida real se soubermos a SECRET.
      # Aqui vamos forçar o comportamento do OpenSSL para garantir o match.
      allow(OpenSSL::HMAC).to receive(:hexdigest).and_return('assinatura_invalida')

      result = subject.parse_notification(params, headers)
      expect(result).to eq('12345')
    end

    it 'loga aviso e processa mesmo com assinatura inválida (conforme implementação atual)' do
      allow(OpenSSL::HMAC).to receive(:hexdigest).and_return('outra_assinatura')
      expect(Rails.logger).to receive(:warn).with(/signature verification failed/)

      subject.parse_notification(params, headers)
    end

    it 'retorna nil se o JSON for inválido ou ocorrer erro' do
      allow(subject).to receive(:verify_signature).and_raise(JSON::ParserError.new('Boom'))
      expect(subject.parse_notification({}, {})).to be_nil
    end
  end

  describe '#get_payment_details' do
    before do
      allow(Curl).to receive(:get).and_yield(curl_mock).and_return(curl_mock)
      allow(curl_mock).to receive(:headers).and_return({})
      allow(described_class).to receive(:sleep)
      allow(subject).to receive(:sleep)
    end

    it 'retorna detalhes com sucesso (200)' do
      allow(curl_mock).to receive(:code).and_return(200)
      allow(curl_mock).to receive(:body).and_return('{"status": "approved"}')

      result = subject.get_payment_details('123')
      expect(result[:successful]).to be true
      expect(result[:details][:status]).to eq('approved')
    end

    it 'faz retries em caso de 404 e desiste depois' do
      allow(curl_mock).to receive(:code).and_return(404)
      allow(curl_mock).to receive(:body).and_return('{}')

      expect(subject).to receive(:sleep).at_least(:once)

      result = subject.get_payment_details('123')

      expect(result[:successful]).to be false
      expect(result[:status]).to eq(404)
    end

    it 'retorna erro de rede (CurlError)' do
      allow(Curl).to receive(:get).and_raise(Curl::Err::CurlError)

      result = subject.get_payment_details('123')
      expect(result[:successful]).to be false
      expect(result[:error_message]).to include('Network error')
    end
  end
end
