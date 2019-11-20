# frozen_string_literal: true

require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'r7_insight'

Gem::Specification.new do |gem|
  gem.name = 'r7insight'
  gem.version = '3.0.1'
  gem.date = Time.now
  gem.summary = 'Rapid7 Insight Platform logging plugin'
  gem.licenses    = ['MIT']
  gem.description = <<DESC
    Rapid7 Insight Platform Ruby library for logging
DESC

  gem.authors = ['Rapid7']
  gem.email = 'InsightOpsTeam@rapid7.com'
  gem.homepage = 'https://github.com/rapid7/r7insight_ruby'
  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'activesupport', '~> 6.0.0'
  gem.add_development_dependency 'bundler', '~> 2.0.0'
  gem.add_development_dependency 'minitest', '~> 5.12.2'
  gem.add_development_dependency 'rake', '~> 13.0.0'
end
