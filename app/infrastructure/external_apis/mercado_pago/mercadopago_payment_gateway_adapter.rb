class MercadopagoPaymentGatewayAdapter
  require "curb"

  def initialize
    @token = ENV.fetch("MERCADOPAGO_TOKEN")
    @user_id = ENV.fetch("MERCADOPAGO_USER_ID")
    @external_pos_id = ENV.fetch("MERCADOPAGO_EXTERNAL_POS_ID")
    @notification_url = ENV.fetch('MERCADOPAGO_NOTIFICATION_URL')
  end

  def generate_qr_payment(pedido_id, total_amount, items)
    # example ('abvas123', 45.50, [{"title": "My product","quantity": 1,"currency_id": "BRL", "unit_measure": "unit", "unit_price": 45.50, "total_amount": 45.50}] )
    params = {
      external_reference: pedido_id,
      title: "SOAT lanches",
      notification_url: @notification_url,
      description: "SOAT lanches",
      total_amount: total_amount.to_f,
      items: items
    }

    http = Curl.post("https://api.mercadopago.com/instore/orders/qr/seller/collectors/#{@user_id}/pos/#{@external_pos_id}/qrs", params.to_json) { |http|
      http.headers["Authorization"] = "Bearer #{@token}"
      http.headers["Content-Type"]="application/json"
    }

    body = JSON.parse(http.body)
    if http.code == 201
      { successful: true, status: http.code, response: body }
    else
      #Rails.logger.error "Mercado Pago API error: #{e.message}"
      { successful: false, status: http.code, error: body }
    end
  end
end