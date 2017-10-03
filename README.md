# IBM::ML
[![Gem Version](https://badge.fury.io/rb/ibm-ml.svg)](https://badge.fury.io/rb/ibm-ml)
[![Build Status](https://travis-ci.org/IBM-ATAT/ibm-ml-ruby.svg?branch=master)](https://travis-ci.org/IBM-ATAT/ibm-ml-ruby)

A Ruby gem to invoke the IBM Machine Learning service REST API.

Currently supports:
- [IBM Watson Machine Learning API](https://watson-ml-api.mybluemix.net/)
- [Machine Learning from DSX Local](https://datascience.ibm.com/docs/content/local/models.html#evaluate-models-with-rest-apis)

## Installation

### With Gem
After [installing Ruby](https://www.ruby-lang.org/en/documentation/installation/) >= 2.0:

```bash
$ gem install ibm-ml
```

### With Bundler
Add this line to your application's Gemfile:

```ruby
gem 'ibm-ml'
```

And then execute:

```bash
$ bundle install
```

## Usage

### Setup
```ruby
require 'ibm/ml'
require 'pp'

# input record to score 
record = {
  GENDER:        'M',
  AGEGROUP:      '45-54',
  EDUCATION:     'Doctorate',
  PROFESSION:    'Executive',
  INCOME:        200000,
  SWITCHER:      0,
  LASTPURCHASE:  3,
  ANNUAL_SPEND:  1200
}
```

### Cloud 
```ruby
CLOUD_USERNAME  =  # WML service username
CLOUD_PASSWORD  =  # WML service password
DEPLOYMENT_ID   =  # deployment ID

# Create the service object
ml_service = IBM::ML::Cloud.new(CLOUD_USERNAME, CLOUD_PASSWORD)

# Fetch an authentication token
pp ml_service.fetch_token

# Query models
pp ml_service.models
pp ml_service.model_by_name('ML Model')

# Query deployments
pp ml_service.deployments
pp ml_service.deployment(DEPLOYMENT_ID)
pp ml_service.deployment_by_name('Deployed ML Model')

# Get a score for the given deployment and record
score = ml_service.score(DEPLOYMENT_ID, record)
score = ml_service.score_by_name('Deployed ML Model', record)
pp score
prediction = ml_service.query_score(score, 'prediction')
probability = ml_service.query_score(score, 'probability')[prediction]
puts
puts "Prediction = #{prediction == 1}"
puts "Probability = #{(probability * 100).round(1)}%"
```

### Local
```ruby
LOCAL_HOST      =  # DSX Local hostname / IP address
LOCAL_USERNAME  =  # DSX Local username
LOCAL_PASSWORD  =  # DSX Local password
DEPLOYMENT_ID   =  # deployment ID

# Create the service object
ml_service = IBM::ML::Local.new(LOCAL_HOST, LOCAL_USERNAME, LOCAL_PASSWORD)

# Fetch an authentication token
pp ml_service.fetch_token

# Get a score for the given deployment and record
pp ml_service.score(DEPLOYMENT_ID, record)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/IBM-ATAT/ibm-ml-ruby](https://github.com/IBM-ATAT/ibm-ml-ruby).

