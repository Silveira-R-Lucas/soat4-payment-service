require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.output_directory = 'coverage/lcov'
SimpleCov::Formatter::LcovFormatter.config.lcov_file_name = 'soat4-payment-service.lcov'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
])

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/config/'
  minimum_coverage 80
end

ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.before(:each) do
    allow(Bunny).to receive(:new).and_return(instance_double(Bunny::Session, start: nil, create_channel: instance_double(Bunny::Channel, fanout: nil, queue: nil)))


    stub_const('ENV', ENV.to_hash.merge(
      'MERCADOPAGO_TOKEN' => 'test_token',
      'MERCADOPAGO_USER_ID' => 'test_user_id',
      'MERCADOPAGO_EXTERNAL_POS_ID' => 'test_pos_id',
      'MERCADOPAGO_NOTIFICATION_URL' => 'http://test.url',
      'MERCADOPAGO_SECRET' => 'test_secret'
    ))
  end
end
