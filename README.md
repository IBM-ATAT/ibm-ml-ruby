# IBM::ML

A Ruby gem to invoke the IBM Machine Learning service REST API.

Currently supports:
- [IBM Watson Machine Learning API](https://watson-ml-api.mybluemix.net/)
- [Machine Learning from DSX Local](https://datascience.ibm.com/docs/content/local/models.html#evaluate-models-with-rest-apis)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ibm-ml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ibm-ml

## Usage

#### Cloud
```ruby
service = IBM::ML::Cloud.new('<ML_SERVICE_USERNAME>', '<ML_SERVICE_PASSWORD>')
p service.fetch_token
p service.published_models
p service.deployments
p service.get_score('<model_guid>', '<deployment_guid>', ['record', 'input', 'values'])
```

#### Local
```ruby
service = IBM::ML::Local.new('<DSX_LOCAL_HOST>', '<DSX_LOCAL_USERNAME>', '<DSX_LOCAL_PASSWORD>')
p service.fetch_token
p service.get_score('<deployment_guid>', ['record', 'input', 'values'])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/IBM-ATAT/ibm-ml-ruby](https://github.com/IBM-ATAT/ibm-ml-ruby).

