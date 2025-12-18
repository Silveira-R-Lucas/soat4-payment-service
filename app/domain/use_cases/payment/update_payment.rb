# frozen_string_literal: true

class UpdatePayment
  def initialize(payment_repository:)
    @payment_repository = payment_repository
  end

  def call(pedido_id:, new_status:, payment_details: nil)
    payment = @payment_repository.find_by_pedido_id(pedido_id)
    raise ArgumentError, "payment with ID #{pedido_id} not found." unless payment

    payment.update_status!(new_status)

    @payment_repository.save(payment)

    payment
  rescue ArgumentError => e
    raise e
  end
end
