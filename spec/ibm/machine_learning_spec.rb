require 'spec_helper'
require 'json'
require 'pp'

RSpec.describe IBM::ML do # rubocop:disable Metrics/BlockLength
  it 'has a version number' do
    expect(IBM::ML::VERSION).not_to be nil
  end

  it 'gets a token from Watson Machine Learning' do
    service = IBM::ML::Cloud.new ENV['CLOUD_USERNAME'], ENV['CLOUD_PASSWORD']
    token   = service.fetch_token
    expect(token).to be_a(String)
  end

  it 'gets models from Watson Machine Learning' do
    service = IBM::ML::Cloud.new ENV['CLOUD_USERNAME'], ENV['CLOUD_PASSWORD']
    result  = service.published_models
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

  it 'gets deployments from Watson Machine Learning' do
    service = IBM::ML::Cloud.new ENV['CLOUD_USERNAME'], ENV['CLOUD_PASSWORD']
    result  = service.deployments
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

  it 'gets specific deployment by name from Watson Machine Learning' do
    service = IBM::ML::Cloud.new ENV['CLOUD_USERNAME'], ENV['CLOUD_PASSWORD']
    result  = service.get_deployment_by_name 'For Testing: Deployed aPhone ML Model'
    expect(result).to be_a Hash
    expect(result).to include 'metadata'
    expect(result).to include 'entity'
  end

  it 'gets model information from deployment information' do
    service = IBM::ML::Cloud.new ENV['CLOUD_USERNAME'], ENV['CLOUD_PASSWORD']
    service.deployments['resources'].each do |deployment|
      model_guid = deployment['entity']['published_model']['guid']
      model_result = service.get_model model_guid
      expect(model_result).to include 'entity'
      expect(model_result['entity']).to include 'input_data_schema'
      expect(model_result['entity']).to include 'deployments'
    end
  end

  it 'gets a score result from Watson Machine Learning' do
    record  = JSON.parse(ENV['RECORD'])
    service = IBM::ML::Cloud.new ENV['CLOUD_USERNAME'], ENV['CLOUD_PASSWORD']
    service.deployments['resources'].each do |deployment|
      model_guid = deployment['entity']['published_model']['guid']
      deployment_guid = deployment['metadata']['guid']
      score = service.get_score model_guid, deployment_guid, record
      expect(score).to be_a(Hash)
      expect(score.keys).to include 'fields'
      expect(score.keys).to include 'values'
      expect(score['fields']).to include 'prediction'
    end
  end

  it 'gets a token from IBM Machine Learning Local' do
    service = IBM::ML::Local.new ENV['LOCAL_HOST'],
                                 ENV['LOCAL_USERNAME'],
                                 ENV['LOCAL_PASSWORD']
    token   = service.fetch_token
    expect(token).to be_a(String)
  end

  it 'gets a score result from IBM Machine Learning Local' do
    record  = JSON.parse(ENV['RECORD'])
    service = IBM::ML::Local.new ENV['LOCAL_HOST'],
                                 ENV['LOCAL_USERNAME'],
                                 ENV['LOCAL_PASSWORD']
    score   = service.get_score ENV['LOCAL_DEPLOYMENT_ID'], record
    expect(score).to be_a(Hash)
  end

  it 'handles bad deployment guid correctly for IBM Machine Learning Local' do
    record  = JSON.parse(ENV['RECORD'])
    service = IBM::ML::Local.new ENV['LOCAL_HOST'],
                                 ENV['LOCAL_USERNAME'],
                                 ENV['LOCAL_PASSWORD']
    expect { service.get_score('blah', record) }.to raise_error(IBM::ML::ScoringError)
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
