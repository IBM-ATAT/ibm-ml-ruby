# IBM::ML
[![Gem Version](https://badge.fury.io/rb/ibm-ml.svg)](https://badge.fury.io/rb/ibm-ml)

A Ruby gem to invoke the IBM Machine Learning service REST API.

Currently supports:
- [IBM Watson Machine Learning API](https://watson-ml-api.mybluemix.net/)
- [Machine Learning from DSX Local](https://datascience.ibm.com/docs/content/local/models.html#evaluate-models-with-rest-apis)

## Installation

#### With Gem
After [installing Ruby](https://www.ruby-lang.org/en/documentation/installation/):

```bash
$ gem install ibm-ml
```

#### With Bundler
Add this line to your application's Gemfile:

```ruby
gem 'ibm-ml'
```

And then execute:

```bash
$ bundle install
```

## Usage

#### Setup
```ruby
require 'ibm/ml'
require 'pp'

# example input record to score 
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

#### Cloud
```ruby
USERNAME =      # ML service username
PASSWORD =      # ML service password
MODEL_ID =      # model ID
DEPLOYMENT_ID = # deployment ID

service = IBM::ML::Cloud.new(USERNAME, PASSWORD)
pp service.fetch_token
pp service.published_models
pp service.deployments
pp service.get_score(MODEL_ID, DEPLOYMENT_ID, record.values)
```

#### Local
```ruby
HOST =          # DSX Local hostname / IP address
USERNAME =      # DSX Local username
PASSWORD =      # DSX Local password
DEPLOYMENT_ID = # deployment ID

service = IBM::ML::Local.new(HOST, USERNAME, PASSWORD)
pp service.fetch_token
pp service.get_score(DEPLOYMENT_ID, record)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/IBM-ATAT/ibm-ml-ruby](https://github.com/IBM-ATAT/ibm-ml-ruby).

