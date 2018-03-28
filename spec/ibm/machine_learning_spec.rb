require 'spec_helper'
require 'json'
require 'pp'

RSpec.describe IBM::ML do # rubocop:disable Metrics/BlockLength
  before(:context) do
    @cloud_service = IBM::ML::Cloud.new ENV['CLOUD_USERNAME'], ENV['CLOUD_PASSWORD'], ENV['CLOUD_INSTANCE_ID']
  end

  it 'has a version number' do
    expect(IBM::ML::VERSION).not_to be nil
  end

  it 'gets a token from Watson Machine Learning' do
    token = @cloud_service.fetch_token
    expect(token).to be_a(String)
  end

  it 'gets HTTPUnauthorized when fetching token with bad credentials' do
    @cloud_service = IBM::ML::Cloud.new 'incorrect_username', 'incorrect_password', 'bad_instance'
    expect do
      @cloud_service.fetch_token
    end.to raise_error(IBM::ML::AuthError, 'User with given credentials not found.')
  end

  it 'gets an error when credentials are valid but deployment does not exist' do
    expect do
      @cloud_service.score 'bad_deployment_guid', RECORD
    end.to raise_error(IBM::ML::QueryError, 'Could not find resource with id "bad_deployment_guid"')
  end

  it 'gets models from Watson Machine Learning' do
    result = @cloud_service.models
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

  it 'gets specific model by name from Watson Machine Learning' do
    result = @cloud_service.model_by_name 'For Testing: aPhone notebook-based ML Model'
    expect(result).to be_a Hash
    expect(result).to include 'metadata'
    expect(result).to include 'entity'
  end

  it 'raises an error if cannot find specific model by name from Watson Machine Learning' do
    expect do
      @cloud_service.model_by_name 'This model name definitely does not exist'
    end.to raise_error(IBM::ML::QueryError,
                       'Could not find resource with name "This model name definitely does not exist"')
  end

  it 'gets deployments from Watson Machine Learning' do
    result = @cloud_service.deployments
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
    result = @cloud_service.deployment_by_name 'For Testing: Deployed aPhone ML Model'
    expect(result).to be_a Hash
    expect(result).to include 'metadata'
    expect(result).to include 'entity'

    id_result = @cloud_service.deployment result['metadata']['guid']
    expect(id_result).to be_a Hash
    expect(id_result).to include 'metadata'
    expect(id_result).to include 'entity'
  end

  it 'raises an error if cannot find specific deployment by name from Watson Machine Learning' do
    expect do
      @cloud_service.deployment_by_name 'This deployment name definitely does not exist'
    end.to raise_error(IBM::ML::QueryError,
                       'Could not find resource with name "This deployment name definitely does not exist"')
  end

  it 'gets model information from deployment information' do
    @cloud_service.deployments['resources'].each do |deployment|
      model_guid   = deployment['entity']['published_model']['guid']
      model_result = @cloud_service.model model_guid
      expect(model_result).to include 'entity'
      expect(model_result['entity']).to include 'input_data_schema'
      expect(model_result['entity']).to include 'deployments'
    end
  end

  it 'gets a score result from Watson Machine Learning' do
    @cloud_service.deployments['resources'].each do |deployment|
      deployment_guid = deployment['metadata']['guid']
      p deployment_guid
      p RECORD

      score = @cloud_service.score deployment_guid, RECORD
      expect(score).to be_a(Hash)
      expect(score.keys).to include 'fields'
      expect(score.keys).to include 'values'

      expect(score['fields']).to include 'prediction'
      prediction = @cloud_service.query_score(score, 'predicTion')
      expect(prediction).to be_a(Numeric)
      expect(prediction).to be(1.0).or(0.0)

      expect(score['fields']).to include 'probability'
      probability = @cloud_service.query_score(score, 'proBability')
      expect(probability).to be_a(Array)
      expect(probability[0]).to be >= 0.0
      expect(probability[0]).to be <= 1.0
      expect(probability[1]).to be >= 0.0
      expect(probability[1]).to be <= 1.0
    end
  end

  it 'gets a score result by deployment name from Watson Machine Learning' do
    score = @cloud_service.score_by_name 'For Testing: Deployed aPhone ML Model', RECORD
    expect(score).to be_a(Hash)
    expect(score.keys).to include 'fields'
    expect(score.keys).to include 'values'
    expect(score['fields']).to include 'prediction'
  end

  it 'gets a score result despite hash being out of order' do
    3.times do
      shuffled_record = RECORD.to_a.shuffle.to_h
      score           = @cloud_service.score_by_name 'For Testing: Deployed aPhone ML Model', shuffled_record
      expect(score).to be_a(Hash)
      expect(score.keys).to include 'fields'
      expect(score.keys).to include 'values'
      expect(score['fields']).to include 'prediction'
    end
  end

  # it 'gets a token from IBM Machine Learning Local' do
  #   service = IBM::ML::Local.new ENV['LOCAL_HOST'],
  #                                ENV['LOCAL_USERNAME'],
  #                                ENV['LOCAL_PASSWORD']
  #   token   = service.fetch_token
  #   expect(token).to be_a(String)
  # end

  # it 'gets a score result from IBM Machine Learning Local' do
  #
  #   service = IBM::ML::Local.new ENV['LOCAL_HOST'],
  #                                ENV['LOCAL_USERNAME'],
  #                                ENV['LOCAL_PASSWORD']
  #   score   = service.score ENV['LOCAL_DEPLOYMENT_ID'], RECORD
  #   expect(score).to be_a(Hash)
  #   expect(score.keys).to include 'fields'
  #   expect(score.keys).to include 'records'
  #
  #   expect(score['fields']).to include 'prediction'
  #   prediction = service.query_score(score, 'predicTion')
  #   expect(prediction).to be_a(Numeric)
  #   expect(prediction).to be(1.0).or(0.0)
  #
  #   expect(score['fields']).to include 'probability'
  #   probability = service.query_score(score, 'proBability')
  #   expect(probability).to be_a(Array)
  #   expect(probability[0]).to be >= 0.0
  #   expect(probability[0]).to be <= 1.0
  #   expect(probability[1]).to be >= 0.0
  #   expect(probability[1]).to be <= 1.0
  # end

  it 'gets Net::HTTPNotFound when fetching token from hostname that is not a DSX instance' do
    service = IBM::ML::Local.new 'www.ibm.com',
                                 'incorrect_CLOUD_USERNAME',
                                 'incorrect_CLOUD_PASSWORD'
    expect { service.fetch_token }.to raise_error(RuntimeError, 'Net::HTTPNotFound')
  end

  # it 'handles authentication error correctly' do
  #   service = IBM::ML::Local.new ENV['LOCAL_HOST'],
  #                                'incorrect_CLOUD_USERNAME',
  #                                'incorrect_CLOUD_PASSWORD'
  #   expect { service.score('blah', RECORD) }.to raise_error(RuntimeError, 'Net::HTTPUnauthorized')
  # end

  # it 'handles bad deployment guid correctly for IBM Machine Learning Local' do
  #
  #   service = IBM::ML::Local.new ENV['LOCAL_HOST'],
  #                                ENV['LOCAL_USERNAME'],
  #                                ENV['LOCAL_PASSWORD']
  #   expect { service.score('blah', RECORD) }.to raise_error(IBM::ML::ScoringError)
  # end

  # it 'gets a token from Machine Learning for z/OS' do
  #   service = IBM::MachineLearning::Zos.new ENV['MLZ_USERNAME'],
  #                                           ENV['MLZ_PASSWORD'],
  #                                           ENV['MLZ_HOST'],
  #                                           ENV['MLZ_LDAP_PORT'], nil
  #   token   = service.fetch_token
  #   expect(token).to be_a(String)
  # end
end

RECORD = { 'GEndER' => 'M', 'AGeGrOUP' => '45-54', 'EDUCaTION' => 'Doctorate', 'PROFEsSION' => 'Executive',
           'IncOME' => 200_000, 'SWItCHER' => 0, 'LASTPURCHASE' => 3, 'ANNuAL_SPEND' => 1200 }.freeze
