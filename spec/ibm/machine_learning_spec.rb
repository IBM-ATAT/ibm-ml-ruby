require 'spec_helper'
require 'pp'

RSpec.describe IBM::MachineLearning do
  it 'has a version number' do
    expect(IBM::MachineLearning::VERSION).not_to be nil
  end

  it 'gets a token from Watson Machine Learning' do
    service = IBM::MachineLearning::Cloud.new ENV['USERNAME'], ENV['PASSWORD']
    token   = service.fetch_token
    expect(token).to be_a(String)
  end

  it 'gets models deployments from Watson Machine Learning' do
    service = IBM::MachineLearning::Cloud.new ENV['USERNAME'], ENV['PASSWORD']
    result  = service.get_models
    expect(result).to be_a Hash
    expect(result).to include 'resources'
    models = result['resources']
    expect(models).to be_a Array
    models.each do |model|
      expect(model).to include 'metadata'
      expect(model).to include 'entity'
      expect(model['entity']).to include 'deployments'
      expect(model['entity']).to include 'training_data_schema'
      expect(model['entity']).to include 'input_data_schema'
    end
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
      expect(deployment['metadata']).to include 'guid'
      expect(deployment).to include 'entity'
      expect(deployment['entity']).to include 'published_model'
      expect(deployment['entity']['published_model']).to include 'guid'
    end
  end

  it 'gets model information from deployment information' do
    service = IBM::MachineLearning::Cloud.new ENV['USERNAME'], ENV['PASSWORD']
    service.get_deployments['resources'].each do |deployment|
      model_result = service.get_model deployment['entity']['published_model']['guid']
      expect(model_result).to include 'entity'
      expect(model_result['entity']).to include 'input_data_schema'
      expect(model_result['entity']).to include 'deployments'
    end
  end

  it 'gets a score result from Watson Machine Learning' do
    record  = JSON.parse(ENV['RECORD'])
    service = IBM::MachineLearning::Cloud.new ENV['USERNAME'], ENV['PASSWORD']
    service.get_deployments['resources'].each do |deployment|
      score = service.get_score deployment['entity']['published_model']['guid'], deployment['metadata']['guid'], record
      expect(score).to be_a(Hash)
      expect(score.keys).to include 'fields'
      expect(score.keys).to include 'values'
      expect(score['fields']).to include 'prediction'
    end
  end

  it 'gets a token from IBM Machine Learning Local' do
    service = IBM::MachineLearning::Local.new ENV['LOCAL_HOST'], ENV['LOCAL_USERNAME'], ENV['LOCAL_PASSWORD']
    token   = service.fetch_token
    expect(token).to be_a(String)
  end

  it 'gets a score result from IBM Machine Learning Local' do
    record  = eval(ENV['LOCAL_RECORD'])
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
