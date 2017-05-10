require 'spec_helper'

RSpec.describe IBM::MachineLearning do
  it 'has a version number' do
    expect(IBM::MachineLearning::VERSION).not_to be nil
  end

  it 'gets a token' do
    service = IBM::MachineLearning::Watson.new ENV['USERNAME'], ENV['PASSWORD']
    token = service.fetch_token
    expect(token).to be_a(String)
  end
end
