# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rom/http/version'

Gem::Specification.new do |spec|
  spec.name          = 'rom-http'
  spec.version       = ROM::HTTP::VERSION.dup
  spec.authors       = ['Piotr Solnica', 'Andy Holland', 'Chris Flipse']
  spec.email         = ['piotr.solnica@gmail.com', 'andyholland1991@aol.com', 'cflipse@gmail.com']
  spec.summary       = 'HTTP support for ROM'
  spec.description   = spec.summary
  spec.homepage      = 'http://rom-rb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'concurrent-ruby'
  spec.add_runtime_dependency 'rom', '~> 3.0.0.rc'
  spec.add_runtime_dependency 'dry-core'
  spec.add_runtime_dependency 'dry-equalizer'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rake', '~> 10.0'
end
