require 'rails_helper'
RSpec.describe ApplicationJob do
  it 'herda de ActiveJob::Base' do
    expect(described_class.superclass).to eq(ActiveJob::Base)
  end
end