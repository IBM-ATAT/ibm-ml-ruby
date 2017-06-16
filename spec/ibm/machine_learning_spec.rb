require 'spec_helper'

RSpec.describe IBM::MachineLearning do
  it 'has a version number' do
    expect(IBM::MachineLearning::VERSION).not_to be nil
  end

  it 'gets a token from Watson Machine Learning' do
    service = IBM::MachineLearning::Cloud.new ENV['USERNAME'], ENV['PASSWORD']
    token   = service.fetch_token
    expect(token).to be_a(String)
  end

  it 'gets online deployments from Watson Machine Learning' do
    service = IBM::MachineLearning::Cloud.new ENV['USERNAME'], ENV['PASSWORD']
    result  = service.get_deployments
    expect(result).to be_a Hash
    expect(result).to include 'resources'
    deployments = result['resources']
    expect(deployments).to be_a Array
    deployments.each do |deployment|
      expect(deployment).to include 'metadata'
      expect(deployment).to include 'entity'
    end
  end

  it 'gets model information from deployment information' do
    service = IBM::MachineLearning::Cloud.new ENV['USERNAME'], ENV['PASSWORD']
    deployments_result = service.get_deployments
    deployment_id = deployments_result['resources'][0]['metadata']['guid']
    model_result = service.get_model deployment_id
    expect(model_result).to be_a Hash
    expect(model_result).to include 'metadata'
    expect(model_result).to include 'entity'
    expect(model_result['entity']).to include 'inputDataSchema'
  end

  it 'gets a score result from Watson Machine Learning' do
    record = JSON.parse(ENV['RECORD'])
    service = IBM::MachineLearning::Cloud.new ENV['USERNAME'], ENV['PASSWORD']
    score   = service.get_score ENV['PREFIX'], ENV['DEPLOYMENT'], record
    expect(score).to be_a(Hash)
  end

  it 'gets a token from IBM Machine Learning Local' do
    service = IBM::MachineLearning::Local.new ENV['LOCAL_HOST'], ENV['LOCAL_USERNAME'], ENV['LOCAL_PASSWORD']
    token   = service.fetch_token
    expect(token).to be_a(String)
  end

  it 'gets a score result from IBM Machine Learning Local' do
    record = eval(ENV['LOCAL_RECORD'])
    service = IBM::MachineLearning::Local.new ENV['LOCAL_HOST'], ENV['LOCAL_USERNAME'], ENV['LOCAL_PASSWORD']
    score   = service.get_score ENV['LOCAL_DEPLOYMENT'], record
    p score
    expect(score).to be_a(Array)
  end

  # it 'gets a token from Machine Learning for z/OS' do
  #   service = IBM::MachineLearning::Zos.new ENV['MLZ_USERNAME'],
  #                                           ENV['MLZ_PASSWORD'],
  #                                           ENV['MLZ_HOST'],
  #                                           ENV['MLZ_LDAP_PORT'], nil
  #   token   = service.fetch_token
  #   expect(token).to be_a(String)
  # end
end
