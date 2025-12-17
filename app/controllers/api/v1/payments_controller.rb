# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ApplicationController
      protect_from_forgery with: :null_session
      require_dependency Rails.root.join('app/infrastructure/persistence/mongo/mongo_payment_repository.rb')
      require_dependency Rails.root.join('app/infrastructure/external_apis/mercado_pago/mercadopago_payment_gateway_adapter.rb')
      require_dependency Rails.root.join('app/domain/use_cases/payment/create_payment.rb')

      def create
        repository = MongoPaymentRepository.new
        gateway = MercadopagoPaymentGatewayAdapter.new
        use_case = CreatePayment.new(payment_repository: repository, payment_gateway: gateway)

        result = use_case.execute(params[:payment][:pedido_id], params[:payment][:total_amount],
                                  params[:payment][:items])
        render json: result, status: :created
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def status
        repository = MongoPaymentRepository.new
        payment = repository.find_by_pedido_id(params[:id])

        if payment
          render json: { "successful": true, "id": payment.payment_id, "payment_status": payment.status }, status: :ok
        else
          render json: { "successful": false, "error": 'Pagamento não encontrado' }, status: :not_found
        end
      end

      def payment_params
        params.permit(:payment).permit(:pedido_id, :total_amount, items:)
      end
    end
  end
end
