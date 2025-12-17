# frozen_string_literal: true

class MercadopagoWebhookAdapter
  require 'digest'
  require 'curb'

  MAX_RETRIES = 6
  RETRY_DELAY_SECONDS = 10

  def initialize
    @secret = ENV.fetch('MERCADOPAGO_SECRET')
    @token = ENV.fetch('MERCADOPAGO_TOKEN')
  end

  def parse_notification(params, headers)
    Rails.logger.warn 'Mercado Pago webhook signature verification failed!' unless verify_signature(params, headers)

    type = params['type'] || params['topic']

    case type
    when 'payment'
      puts params
      params['data.id']
    when 'merchant_order'
      Rails.logger.info "Received Mercado Pago merchant_order notification: #{params[:id]}"
      puts params
      params['data.id']
    else
      Rails.logger.warn "Received unknown Mercado Pago webhook type: #{type}"
      nil
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Invalid JSON in Mercado Pago webhook: #{e.message}"
    nil
  rescue StandardError => e
    Rails.logger.error "Error parsing Mercado Pago webhook: #{e.message}"
    nil
  end

  def get_payment_details(payment_id)
    attempts = 0

    begin
      attempts += 1
      Rails.logger.info "Attempt #{attempts} to get Mercado Pago payment details for ID: #{payment_id}"

      http = Curl.get("https://api.mercadopago.com/v1/payments/#{payment_id}") do |http_client|
        http_client.headers['Authorization'] = "Bearer #{@token}"
        http_client.headers['Content-Type'] = 'application/json'
      end

      body = JSON.parse(http.body).deep_symbolize_keys

      if http.code == 200
        { successful: true, status: http.code, details: body }
      elsif http.code == 404 && attempts < MAX_RETRIES
        Rails.logger.warn "Mercado Pago API returned 404 for payment ID #{payment_id}. Retrying in #{RETRY_DELAY_SECONDS} seconds..."
        sleep RETRY_DELAY_SECONDS
        raise 'Retry required'
      else
        Rails.logger.error "Mercado Pago API (get_payment_details) error: #{http.code} - #{body[:message]} for ID #{payment_id}"
        { successful: false, status: http.code, error_message: body[:message] }
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid JSON response from Mercado Pago API for ID #{payment_id}: #{e.message}"
      { successful: false, error_message: 'Invalid API response JSON.' }
    rescue Curl::Err::CurlError => e
      Rails.logger.error "Curl error connecting to Mercado Pago API for ID #{payment_id}: #{e.message}"
      { successful: false, error_message: 'Network error connecting to payment gateway.' }
    rescue StandardError => e
      if e.message == 'Retry required' && attempts < MAX_RETRIES
        retry
      else
        Rails.logger.error "Unexpected error getting Mercado Pago payment details for ID #{payment_id}: #{e.message}"
        { successful: false, error_message: 'Unexpected error from payment gateway.' }
      end
    end
  end

  private

  def verify_signature(params, headers)
    signature = headers['HTTP_X_SIGNATURE'].split(',').second.split('=').second
    payload = "id:#{params['data']['id']};request-id:#{headers['HTTP_X_REQUEST_ID']};ts:#{headers['HTTP_X_SIGNATURE'].split(',').first.split('=').second};"
    encoded_payload = OpenSSL::HMAC.hexdigest('SHA256', @secret, payload)

    encoded_payload == signature
  end
end
