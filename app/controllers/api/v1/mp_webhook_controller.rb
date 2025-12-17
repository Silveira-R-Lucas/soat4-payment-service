class Api::V1::MpWebhookController < ActionController::API
  require "digest"
  include ActionController::MimeResponds

  def payment_notification
    raw_data = request.body.read
    headers = request.headers.to_h

    process_notification_service = ProcessMercadopagoNotification.new(
      mercadopago_webhook_adapter: MercadopagoWebhookAdapter.new,
      payment_repository: MongoPaymentRepository.new
    )

    begin
      success = process_notification_service.call(params: params, headers: headers)

      if success
        render json: { "successful": true, "status": 200, error: "Pagamento atualizado!" }, status: :ok
      else
        head :unprocessable_entity
      end
    rescue ArgumentError => e
      Rails.logger.error "Webhook processing error: #{e.message}"
      render json: { "successful": false, "status": 400, error: "status inválido: #{e.message}" }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error "Unexpected error processing webhook: #{e.message}"
      render json: { "successful": false, "status": 500, error: "#{e.message}" }, status: :internal_server_error
    end
  end

  def webhook_params
    params.permit(:action, :api_version, :data, :date_created, :id, :live_mode, :type, :user_id, :mp_webhook, :data)
  end
end
