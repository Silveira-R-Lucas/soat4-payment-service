# frozen_string_literal: true

class CreatePayment
  def initialize(payment_repository:, payment_gateway:)
    @payment_repository = payment_repository
    @payment_gateway = payment_gateway
  end

  def execute(pedido_id, total_amount, items)
    mp_response = @payment_gateway.generate_qr_payment(pedido_id, total_amount, items)
    payment = Payment.new(
      pedido_id: pedido_id,
      amount: total_amount,
      payment_id: mp_response[:response]['in_store_order_id'],
      qr_data: mp_response[:response]['qr_data'],
      items: items
    )

    if payment
      @payment_repository.save(payment)
      { "successful": true, payment_status: 'created', pedido_id: pedido_id,
        payment_details: mp_response[:response]['qr_data'] }
    end
  rescue StandardError => e
    { "successful": false, error: e.message }
  end
end
