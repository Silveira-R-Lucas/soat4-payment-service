# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentNotification do
  subject do
    described_class.new(
      id: '123',
      status: 'approved',
      amount: 50.0,
      external_reference: 'ped_1',
      payment_method: 'pix'
    )
  end

  it 'inicializa com os atributos corretos' do
    expect(subject.id).to eq('123')
    expect(subject.amount).to eq(50.0)
  end

  it 'responde true para approved?' do
    expect(subject.approved?).to be true
  end

  it 'responde false para approved? se status for outro' do
    notification = described_class.new(
      id: '1', status: 'pending', amount: 0, external_reference: '', payment_method: ''
    )
    expect(notification.approved?).to be false
  end
end
