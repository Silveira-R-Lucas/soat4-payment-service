require 'simplecov'

module SimpleCov
  module Formatter
    class SonarGenericFormatter
      def format(result)
        xml = ['<coverage version="1">']
        
        result.files.each do |file|
          clean_path = file.project_filename.gsub(/^(\.\/|\/)/, '')
          
          xml << "  <file path=\"#{clean_path}\">"
          file.lines.each do |line|
            next if line.never? || line.skipped? || line.coverage.nil?
            
            is_covered = line.covered? ? 'true' : 'false'
            xml << "    <lineToCover lineNumber=\"#{line.number}\" covered=\"#{is_covered}\"/>"
          end
          xml << "  </file>"
        end
        xml << '</coverage>'
        
        Dir.mkdir(SimpleCov.coverage_path) unless Dir.exist?(SimpleCov.coverage_path)
        file_path = File.join(SimpleCov.coverage_path, 'sonarqube.xml')
        
        File.write(file_path, xml.join("\n"))
        puts "::notice:: Relatório SonarQube gerado em: #{file_path}"
      end
    end
  end
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::SonarGenericFormatter
])

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/config/'
  minimum_coverage 80
  enable_coverage :branch
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
