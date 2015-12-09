# coding: utf-8
version = File.read(File.expand_path('../WHALES_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "whales"
  spec.version       = version
  spec.authors       = ["William Horton"]
  spec.email         = ["wdt.horton@gmail.com"]
  spec.summary       = %q{A full-stack MVC framework in Ruby}
  spec.homepage      = "https://github.com/wdhorton/whales"
  spec.license       = "MIT"

  spec.files         = ['README.md', 'exe/whales']

  spec.bindir       = 'exe'
  spec.executables   = ["whales"]

  spec.add_dependency "bundler", "~> 1.10"
  spec.add_dependency "rake", "10.4.2"

  spec.add_dependency "whales_actions", version
  spec.add_dependency "whales_orm", version
end
