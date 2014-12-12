# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opium/version'

Gem::Specification.new do |spec|
  spec.name          = "opium"
  spec.version       = Opium::VERSION
  spec.authors       = ["Joshua Bowers"]
  spec.email         = ["joshua.bowers+code@gmail.com"]
  spec.summary       = %q{An Object Parse.com Mapping technology for defining models.}
  spec.description   = %q{Provides an intuitive, Mongoid-inspired mapping layer being your application's object space and Parse.'}
  spec.homepage      = "https://github.com/joshuabowers/opium"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "coveralls"
  
  spec.add_dependency "activemodel", "~> 3.2.18"
  spec.add_dependency "gem_config", "~> 0.3.1"
  spec.add_dependency "faraday", "~> 0.9.0"
  spec.add_dependency "faraday_middleware", "~> 0.9.1"
end
