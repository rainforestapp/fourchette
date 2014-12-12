# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fourchette/version'

Gem::Specification.new do |spec|
  spec.name          = 'fourchette'
  spec.version       = Fourchette::VERSION
  spec.authors       = ['Jean-Philippe Boily']
  spec.email         = ['j@jipi.ca']
  spec.summary       = 'Your new best friend for isolated testing environments on Heroku.'
  spec.description   = "Fourchette is your new best friend for having isolated testing environment. It will help you test your GitHub PRs against a fork of one your Heroku apps. You will have one Heroku app per PR now. Isn't that amazing? It will make testing way easier and you won't have the (maybe) broken code from other PRs on staging but only the code that requires testing."
  spec.homepage      = 'https://github.com/jipiboily/fourchette'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rake'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'sinatra-contrib'
  spec.add_dependency 'octokit'
  spec.add_dependency 'git'
  spec.add_dependency 'heroku', '~> 3.9' # Deprecated, but best/easiest solution for pgbackups...
  spec.add_dependency 'rest-client' # required for phbackups
  spec.add_dependency 'platform-api', '~> 0.2.0'
  spec.add_dependency 'sucker_punch'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'foreman'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'terminal-notifier-guard'
  spec.add_development_dependency 'coveralls'
end
