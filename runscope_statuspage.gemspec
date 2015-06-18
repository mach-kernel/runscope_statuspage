# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'runscope_statuspage/version'

Gem::Specification.new do |spec|
  spec.name          = 'runscope_statuspage'
  spec.version       = RunscopeStatuspage::VERSION
  spec.authors       = ['David Stancu']
  spec.email         = ['dstancu@nyu.edu']

  spec.summary       = 'Push RunScope data to StatusPage.io'
  spec.description   = 'Get test data from RunScope and easily report incidents to StatusPage.io, all with one gem.'
  spec.homepage      = 'https://github.com/mach-kernel/runscope_statuspage'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('\x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
end
