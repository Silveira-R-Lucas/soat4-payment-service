class PaymentNotification
  attr_reader :id, :status, :amount, :external_reference, :payment_method, :received_at

  def initialize(id:, status:, amount:, external_reference:, payment_method:, received_at: Time.current)
    @id = id
    @status = status
    @amount = amount
    @external_reference = external_reference
    @payment_method = payment_method
    @received_at = received_at
  end

  def approved?
    status == "approved"
  end
end
