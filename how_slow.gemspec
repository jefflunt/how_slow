# -*- encoding: utf-8 -*-
require File.expand_path('../lib/how_slow/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jeff Lunt"]
  gem.email         = ["jefflunt@gmail.com"]
  gem.description   = %q{A gem for collecting Rails app performance metrics and reporting on those numbers via email}
  gem.summary       = %q{A gem for collecting Rails app performance metrics and reporting on those numbers via email}
  gem.homepage      = 'https://github.com/normalocity/how_slow'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'how_slow'
  gem.require_paths = ["lib"]
  gem.version       = HowSlow::VERSION
  
  gem.add_dependency 'activesupport','>3.0'
end

