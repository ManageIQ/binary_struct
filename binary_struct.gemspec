# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'binary_struct/version'

Gem::Specification.new do |spec|
  spec.name          = "binary_struct"
  spec.version       = BinaryStruct::VERSION
  spec.authors       = ["Oleg Barenboim", "Jason Frey"]
  spec.email         = ["chessbyte@gmail.com", "fryguy9@gmail.com"]
  spec.description   = %q{
BinaryStruct is a class for dealing with binary structured data.  It simplifies
expressing what the binary structure looks like, with the ability to name the
parts.  Given this definition, it is easy to encode/decode the binary structure
from/to a Hash.
}
  spec.summary       = %q{BinaryStruct is a class for dealing with binary structured data.}
  spec.homepage      = "http://github.com/ManageIQ/binary_struct"
  spec.license       = "MIT"

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.files        += %w[README.md LICENSE.txt]
  spec.executables   = `git ls-files -- bin/*`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.test_files   += %w[.rspec]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.99"
  spec.add_development_dependency "coveralls"
end
