class Payment
  attr_accessor :pedido_id, :amount, :status, :payment_id, :qr_data, :items

  def initialize(pedido_id:, amount:, items:, status: 'PENDENTE', payment_id: nil, qr_data: nil)
    @pedido_id = pedido_id
    @amount = amount
    @status = status
    @payment_id = payment_id
    @qr_data = qr_data
    @items = items
  end

  def mark_as_paid!
    @status = 'PAGO'
  end

  def paid?
    @status == 'PAGO'
  end

  def update_status!(new_status)
    @status = new_status
  end
end

