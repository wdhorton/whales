# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whales_actions/version'

Gem::Specification.new do |spec|
  spec.name          = "whales_actions"
  spec.version       = WhalesActions::VERSION
  spec.authors       = ["William Horton"]
  spec.email         = ["wdt.horton@gmail.com"]
  spec.summary       = %q{The VC in the Whales MVC framework}
  spec.homepage      = "https://github.com/wdhorton/whales/tree/master/whales_actions"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "json", "1.8.3"
  spec.add_dependency "webrick"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
end
