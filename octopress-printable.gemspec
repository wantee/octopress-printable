# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress-printable/version'

Gem::Specification.new do |spec|
  spec.name          = "octopress-printable"
  spec.version       = Octopress::Printable::VERSION
  spec.authors       = ["Wang Jian"]
  spec.email         = ["wantee.wang@gmail.com"]
  spec.description   = %q{Printable version for post generator.}
  spec.summary       = %q{Printable version for post generator.}
  spec.homepage      = "https://github.com/wantee/jekyll-printable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r{^(bin/|lib/|assets/|changelog|readme|license)}i)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "clash", "~> 2.2.2"

  spec.add_development_dependency "octopress-image-tag", "~>1.1.0"
  spec.add_development_dependency "octopress-gist", "~>1.3.5"
  spec.add_development_dependency "octopress-ink"
  spec.add_development_dependency "jekyll-scholar", "~>4.3.5"
end
