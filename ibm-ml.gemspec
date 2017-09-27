# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ibm/ml/version'

Gem::Specification.new do |spec|
  spec.name          = 'ibm-ml'
  spec.version       = IBM::ML::VERSION
  spec.license       = 'Apache-2.0'
  spec.author        = 'David Thomason'
  spec.email         = 'dlthomas@us.ibm.com'
  spec.summary       = 'Client library for calling IBM Machine Learning API'
  spec.description   = 'Simplifies development of applications using an IBM Machine Learning service '\
                       'by providing methods for getting deployments and calling them. '\
                       'Operates with both IBM Watson Machine Learning as well as Machine Learning on DSX Local.'
  spec.homepage      = 'https://github.com/IBM-ATAT/ibm-ml-ruby'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.49'
end
