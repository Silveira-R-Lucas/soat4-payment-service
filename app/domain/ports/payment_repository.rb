module Payment
  class PaymentRepository
    def save(payment)
      raise NotImplementedError
    end

    def find_by_pedido_id(pedido_id)
      raise NotImplementedError
    end
  end
end