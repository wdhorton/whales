# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinderella/version'

Gem::Specification.new do |spec|
  spec.name          = "whales_actions"
  spec.version       = Whales::VERSION
  spec.authors       = ["William Horton"]
  spec.email         = ["wdt.horton@gmail.com"]
  spec.summary       = %q{The VC in the Whales MVC framework}
  spec.homepage      = "https://github.com/wdhorton/whales/tree/master/whales_actions"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
