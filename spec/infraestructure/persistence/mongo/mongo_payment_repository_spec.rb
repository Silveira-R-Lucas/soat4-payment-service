# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MongoPaymentRepository do
  subject { described_class.new }

  describe '#save' do
    let(:payment) { build(:payment, payment_id: 'MP_123', pedido_id: 'PED_1', amount: 50.0) }

    it 'cria um novo documento se não existir' do
      result = subject.save(payment)

      expect(result).to be_a(Payment::Payment)
      doc = PaymentDocument.find_by(payment_id: 'MP_123')
      expect(doc).not_to be_nil
      expect(doc.amount).to eq(50.0)
    end

    it 'atualiza o documento se já existir' do
      PaymentDocument.create!(payment_id: 'MP_123', pedido_id: 'PED_1', amount: 10.0)

      # Pagamento com mesmo ID mas valor novo
      payment.amount = 99.0
      subject.save(payment)

      doc = PaymentDocument.find_by(payment_id: 'MP_123')
      expect(doc.amount).to eq(99.0)
    end
  end

  describe '#find_by_pedido_id' do
    it 'retorna o domínio Payment quando encontra' do
      PaymentDocument.create!(payment_id: 'MP_123', pedido_id: 'PED_BUSCA', amount: 10.0)

      result = subject.find_by_pedido_id('PED_BUSCA')

      expect(result).to be_a(Payment::Payment)
      expect(result.pedido_id).to eq('PED_BUSCA')
    end

    it 'retorna nil se não encontrar' do
      expect(subject.find_by_pedido_id('INEXISTENTE')).to be_nil
    end
  end
end
