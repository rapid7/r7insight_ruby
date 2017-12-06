# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'le'

Gem::Specification.new do |gem|
  gem.name	= "r7insight"
  gem.version	= "2.7.6"
  gem.date	= Time.now
  gem.summary	= "InsightOps logging plugin"
  gem.licenses    = ["MIT"]
  gem.description	=<<EOD


EOD

  gem.authors	= ["Mark Lacomber", "Stephen Hynes"]
  gem.email	= "support@rapid7.com"
  gem.homepage    = "https://github.com/rapid7/r7insight_ruby"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency 'minitest'

end
