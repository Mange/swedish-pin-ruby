require_relative "lib/swedish_pin/version"

Gem::Specification.new do |s|
  s.name = "swedish-pin"
  s.version = SwedishPIN::VERSION
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  s.license = "MIT"
  s.summary = "Work with Swedish PINs (Personnummer)"
  s.description = "Parse, validate, and generate Swedish Personal Identity Numbers (PINs / Personnummer)"
  s.homepage = "https://github.com/Mange/swedish-pin-ruby"

  s.authors = ["Magnus Bergmark", "Jack Millard", "Fredrik Forsmo"]
  s.email = ["me@mange.dev", "millard64@hotmail.co.uk", "fredrik.forsmo@gmail.com"]

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "standard"
end
