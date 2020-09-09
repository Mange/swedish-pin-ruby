$:.push File.expand_path("../lib", __FILE__)
require "swedish_pin/version"

Gem::Specification.new do |s|
  s.name = "swedish-pin"
  s.version = SwedishPIN::VERSION
  s.date = "2020-08-09"
  s.summary = "Work with Swedish PINs (Personnummer)"
  s.description = "Parse, validate, and generate Swedish Personal Identity Numbers (PINs / Personnummer)"
  s.authors = ["Magnus Bergmark", "Jack Millard", "Fredrik Forsmo"]
  s.email = ["me@mange.dev", "millard64@hotmail.co.uk", "fredrik.forsmo@gmail.com"]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.homepage = "https://github.com/Mange/swedish-pin-ruby"
  s.license = "MIT"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "standard"
end
