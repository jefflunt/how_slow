# -*- encoding: utf-8 -*-
require File.expand_path('../lib/how_slow/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jeff Lunt"]
  gem.email         = ["jefflunt@gmail.com"]
  gem.description   = %q{A gem for collecting Rails application metrics. No server or 3rd party services required.}
  gem.summary       = %q{Collect Rails performance metrics without 3rd party services or extra servers.}
  gem.homepage      = 'https://github.com/jefflunt/how_slow'
  gem.license       = 'MIT'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test}/*`.split("\n")
  gem.name          = 'how_slow'
  gem.require_paths = ['lib']
  gem.version       = HowSlow::VERSION
  
  gem.add_dependency 'activesupport','~>3.1'
  gem.add_dependency 'actionmailer','~>3.1'
  gem.add_dependency 'rails','~>3.1'

  gem.add_development_dependency 'rake','~>10.0.4'
  gem.add_development_dependency 'pry','~>0.9.12'
  gem.add_development_dependency 'minitest','~>4.7.1'
  gem.add_development_dependency 'minitest-spec-context','~>0.0.3'
  gem.add_development_dependency 'turn','~>0.9.6'
  gem.add_development_dependency 'mocha','~>0.13'
end

