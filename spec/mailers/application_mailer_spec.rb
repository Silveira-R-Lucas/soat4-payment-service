require 'rails_helper'
RSpec.describe ApplicationMailer do
  it 'herda de ActionMailer::Base' do
    expect(described_class.superclass).to eq(ActionMailer::Base)
  end
end