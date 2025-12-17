require 'rails_helper'

RSpec.describe RabbitmqConnection do
  let(:bunny_session) { instance_double(Bunny::Session) }
  let(:channel) { instance_double(Bunny::Channel) }

  before do
    allow(Bunny).to receive(:new).and_return(bunny_session)
    allow(bunny_session).to receive(:start)
    allow(bunny_session).to receive(:create_channel).and_return(channel)
    allow(described_class).to receive(:puts)
    allow(described_class).to receive(:sleep)
  end

  it 'inicia a conexão e cria o canal' do
    expect(described_class.channel).to eq(channel)
  end

  it 'realiza retries em caso de falha de conexão' do
    call_count = 0
    allow(bunny_session).to receive(:start) do
      call_count += 1
      raise Bunny::TCPConnectionFailedForAllHosts if call_count == 1
    end

    expect(described_class).to receive(:sleep).once
    expect(described_class.start).to eq(bunny_session)
  end
end