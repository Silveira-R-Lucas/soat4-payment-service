# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RabbitmqPublisher do
  let(:channel) { instance_double(Bunny::Channel) }
  let(:exchange) { instance_double(Bunny::Exchange) }

  subject { described_class.new('test.exchange') }

  before do
    allow(RabbitmqConnection).to receive(:channel).and_return(channel)
    allow(channel).to receive(:fanout).with('test.exchange', durable: true).and_return(exchange)
  end

  it 'publica mensagem JSON no exchange' do
    expect(exchange).to receive(:publish) do |msg|
      data = JSON.parse(msg)
      expect(data['event']).to eq('TestEvent')
      expect(data['payload']).to eq({ 'foo' => 'bar' })
    end

    subject.publish('TestEvent', { foo: 'bar' })
  end
end
