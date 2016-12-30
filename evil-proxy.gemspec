# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'evil-proxy/version'

Gem::Specification.new do |spec|
  spec.name          = "evil-proxy"
  spec.version       = EvilProxy::VERSION
  spec.authors       = ["Theo"]
  spec.email         = ["bbtfrr@gmail.com"]
  spec.summary       = %q{A ruby http/https proxy to do EVIL things.}
  spec.description   = %q{A ruby http/https proxy, with SSL MITM support.}
  spec.homepage      = "https://github.com/bbtfr/evil-proxy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
