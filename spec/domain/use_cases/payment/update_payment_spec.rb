require 'rails_helper'

RSpec.describe UpdatePayment do
  let(:repository) { instance_double(MongoPaymentRepository) }
  subject { described_class.new(payment_repository: repository) }

  describe '#call' do
    let(:payment) { build(:payment, status: "PENDENTE") }

    it 'atualiza o status do pagamento' do
      allow(repository).to receive(:find_by_pedido_id).with("123").and_return(payment)
      expect(repository).to receive(:save).with(payment)

      updated = subject.call(pedido_id: "123", new_status: "PAGO")
      
      expect(updated.status).to eq("PAGO")
    end

    it 'lança erro se pagamento não encontrado' do
      allow(repository).to receive(:find_by_pedido_id).and_return(nil)
      
      expect {
        subject.call(pedido_id: "999", new_status: "PAGO")
      }.to raise_error(ArgumentError, /payment with ID 999 not found/)
    end
  end
end