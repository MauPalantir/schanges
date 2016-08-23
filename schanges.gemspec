require_relative 'lib/schanges/version'

Gem::Specification.new do |spec|
  spec.name          = "schanges"
  spec.version       = Schanges::VERSION
  spec.authors       = ["Mau Zsófia Ábrahám"]
  spec.email         = ["mau.palantir@gmail.com"]

  spec.summary       = %q{Simulate phonetic changes of natural languages.}
  spec.description   = %q{Ruby implementation of Mark Rosenfelder’s SCA.}
  spec.homepage      = "https://github.com/MauPalantir/schanges"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'thor', '~> 0.19'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
