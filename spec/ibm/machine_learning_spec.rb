require 'spec_helper'

RSpec.describe IBM::MachineLearning do
  it 'has a version number' do
    expect(IBM::MachineLearning::VERSION).not_to be nil
  end

  it 'gets a token from Watson Machine Learning' do
    service = IBM::MachineLearning::Watson.new ENV['USERNAME'], ENV['PASSWORD']
    token = service.fetch_token
    expect(token).to be_a(String)
  end

  it 'gets a token from Machine Learning for z/OS' do
    service = IBM::MachineLearning::Zos.new ENV['MLZ_USERNAME'], ENV['MLZ_PASSWORD'], ENV['MLZ_HOST'], ENV['MLZ_LDAP_PORT'], nil
    token = service.fetch_token
    expect(token).to be_a(String)
  end
end
