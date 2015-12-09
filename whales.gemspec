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

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_dependency "bundler"
  spec.add_dependency "whales_actions", version
  spec.add_dependency "whales_orm", version
end
