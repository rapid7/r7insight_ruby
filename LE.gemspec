# frozen_string_literal: true

require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'le'

Gem::Specification.new do |gem|
  gem.name = 'r7insight'
  gem.version = '2.7.6'
  gem.date = Time.now
  gem.summary = 'InsightOps logging plugin'
  gem.licenses    = ['MIT']
  gem.description = <<DESC


DESC

  gem.authors = ['Mark Lacomber', 'Stephen Hynes']
  gem.email = 'support@rapid7.com'
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
