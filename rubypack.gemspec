# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubypack/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubypack'
  spec.version       = Rubypack::VERSION
  spec.authors       = ['Jorge del Rio']
  spec.email         = ['jorge.delrio@kueski.com']

  spec.summary       = 'Gem to build and deploy packages of your application'
  spec.description   = 'This gem provides some utilities to build a package of your application' +
                       ' with aims to provide a runnable standalone application that can be shared' +
                       ' or deployed in production systems.'
  spec.homepage      = 'https://github.com/newint33h/rubypack.git'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'bundler', '~> 1.14'
  spec.add_runtime_dependency 'trollop', '~> 2.1'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
