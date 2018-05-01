
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fsa/version"

Gem::Specification.new do |spec|
  spec.name          = "fsa"
  spec.version       = Fsa::VERSION
  spec.authors       = ["Chihiro Hasegawa"]
  spec.email         = ["register.chihiro@gmail.com"]

  spec.summary       = %q{Generating payload of format string bug}
  spec.description   = %q{Generating payload of format string bug}
  spec.license       = "MIT"
  spec.homepage      = "https://github.com/owlinux1000/fsalib"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
