
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "progresso/version"

Gem::Specification.new do |spec|
  spec.name          = "progresso"
  spec.version       = Progresso::VERSION
  spec.authors       = ["Hakim Aryan"]
  spec.email         = ["hakim.aryan@cpoms.co.uk"]

  spec.summary       = %q{Progresso API client}
  spec.homepage      = "http://www.cpoms.co.uk"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "excon", '~> 0.62.0'
  spec.add_runtime_dependency 'activesupport', ">= 4"

  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
end
