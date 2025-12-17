require 'rails_helper'
RSpec.describe ApplicationCable::Connection, type: :channel do
  it 'existe' do
    expect(described_class).to be_truthy
  end
end