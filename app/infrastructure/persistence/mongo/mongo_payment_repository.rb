class MongoPaymentRepository
  def save(payment)
    doc = PaymentDocument.where(payment_id: payment.payment_id).first

    if doc
      doc.update!(
        pedido_id: payment.pedido_id,
        amount: payment.amount,
        status: payment.status,
        qr_data: payment.qr_data,
        items: payment.items
      )
    else
      doc = PaymentDocument.create!(
        payment_id: payment.payment_id,
        pedido_id: payment.pedido_id,
        amount: payment.amount,
        status: payment.status,
        qr_data: payment.qr_data,
        items: payment.items
      )
    end

    doc.to_domain
  end

  def find_by_pedido_id(pedido_id)
    PaymentDocument.where(pedido_id: pedido_id).first&.to_domain
  end
end
