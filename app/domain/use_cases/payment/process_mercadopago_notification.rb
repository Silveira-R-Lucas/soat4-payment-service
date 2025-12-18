# frozen_string_literal: true

class ProcessMercadopagoNotification
  def initialize(mercadopago_webhook_adapter:, payment_repository:)
    @mercadopago_webhook_adapter = mercadopago_webhook_adapter
    @payment_repository = payment_repository
  end

  def call(params:, headers:)
    payment_id = @mercadopago_webhook_adapter.parse_notification(params, headers)
    return false unless payment_id

    payment_details_result = @mercadopago_webhook_adapter.get_payment_details(payment_id)

    unless payment_details_result[:successful]
      Rails.logger.error "Falha ao pegar detalhes do pagamento pela API do Mercado Pago: #{payment_details_result[:error]}"
      return false
    end

    full_payment_data = payment_details_result[:details]

    notification = PaymentNotification.new(
      id: full_payment_data[:id],
      status: full_payment_data[:status],
      amount: full_payment_data[:transaction_amount] || 0.0,
      external_reference: full_payment_data[:external_reference],
      payment_method: full_payment_data[:payment_method_id]
    )

    payment = @payment_repository.find_by_pedido_id(full_payment_data[:external_reference])
    raise ArgumentError, "Número de pedido #{full_payment_data[:external_reference]} não encontrado." unless payment

    UpdatePayment.new(payment_repository: MongoPaymentRepository.new)
                 .call(
                   pedido_id: notification.external_reference,
                   new_status: notification.status
                 )

    publisher = RabbitmqPublisher.new('pagamento.events')
    if notification.approved?
      publisher.publish('PagamentoAprovado', {
                          pedido_id: notification.external_reference,
                          status: notification.status,
                          items: payment.items
                        })
      true
    else
      publisher.publish('PagamentoNegado', {
                          pedido_id: notification.external_reference,
                          status: notification.status
                        })
      false
    end
  rescue StandardError => e
    Rails.logger.error "Erro ao processar notificação do Mercado Pago: #{e.message}"
    false
  end
end
