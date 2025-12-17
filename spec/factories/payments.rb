# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: 'Payment::Payment' do
    pedido_id { Faker::Number.number(digits: 4).to_s }
    amount { Faker::Commerce.price.to_f }
    status { 'PENDENTE' }
    payment_id { Faker::Number.number(digits: 8).to_s }
    qr_data { 'qr_code_data_string' }
    items { [{ title: 'Item 1', unit_price: 10.0, quantity: 1 }] }

    # Necessário para objetos de domínio puro (PORO)
    initialize_with { new(**attributes) }
  end
end
