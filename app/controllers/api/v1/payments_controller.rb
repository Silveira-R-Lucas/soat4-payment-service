module Api
  module V1
    class PaymentsController < ApplicationController
      protect_from_forgery with: :null_session
      require_dependency Rails.root.join("app/infrastructure/persistence/mongo/mongo_payment_repository.rb")
      require_dependency Rails.root.join("app/infrastructure/external_apis/mercado_pago/mercadopago_payment_gateway_adapter.rb")
      require_dependency Rails.root.join("app/domain/use_cases/payment/create_payment.rb")

      def create
        repository = MongoPaymentRepository.new
        gateway = MercadopagoPaymentGatewayAdapter.new
        use_case = CreatePayment.new(payment_repository: repository, payment_gateway: gateway)

        result = use_case.execute(params[:payment][:pedido_id], params[:payment][:total_amount], params[:payment][:items])
        render json: result, status: :created
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def status
        render json:  { "successful": true, "status": 200,  id: @cart.id, payment_status: @cart.payment_status }, status: :ok
      end

      def payment_params
        params.require(:payment).permit(:pedido_id, :total_amount, items:)
      end
    end
  end
end
