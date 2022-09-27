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
  spec.homepage      = 'https://rom-rb.org'
  spec.license       = 'MIT'

  spec.files         = Dir['CHANGELOG.md', 'LICENSE.txt', 'README.md', 'lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.1'
  spec.add_runtime_dependency 'addressable', '~> 2.6'
  spec.add_runtime_dependency 'rom', '~> 5.0', '>= 5.0.1'
  spec.add_runtime_dependency 'dry-core', '~> 0.4'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.13'
end
