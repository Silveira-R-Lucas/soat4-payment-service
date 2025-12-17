# frozen_string_literal: true

class PaymentDocument
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'payments'

  field :pedido_id, type: String
  field :amount, type: Float
  field :status, type: String
  field :payment_id, type: String
  field :qr_data, type: String
  field :items, type: Array

  index({ payment_id: 1 }, unique: true)
  index({ pedido_id: 1 })

  def to_domain
    ::Payment::Payment.new(
      pedido_id: pedido_id,
      amount: amount,
      status: status,
      payment_id: payment_id,
      qr_data: qr_data,
      items: items
    )
  end
end
