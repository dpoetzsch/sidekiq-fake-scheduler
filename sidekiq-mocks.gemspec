# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq_mocks/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq-mocks'
  spec.version       = SidekiqMocks::VERSION
  spec.authors       = ['David Poetzsch-Heffter']
  spec.email         = ['davidpoetzsch@web.de']

  spec.summary       = 'Helpers for manual processing of scheduled sidekiq jobs for integration testing'
  spec.description   = "This gem provides behavior similar to sidekiq's inline mode but respects starting " \
    'dates for scheduled jobs. This is especially useful for integration testing when asserting that certain ' \
    'things happen within a certain time frame.'
  spec.homepage      = 'https://github.com/dpoetzsch/sidekiq-mocks'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sidekiq', '~> 5.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'timecop'
end
