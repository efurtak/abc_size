# frozen_string_literal: true

require_relative 'lib/abc_size/version'

Gem::Specification.new do |spec|
  spec.name = 'abc_size'
  spec.version = AbcSize::VERSION
  spec.authors = ['Emil Furtak']
  spec.email = ['emil.furtak@gmail.com']

  spec.summary = 'Calculate ABC size.'
  spec.description = 'Calculate ABC size, divided into methods defined in a single file.'
  spec.homepage = 'https://github.com/efurtak/abc_size'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/efurtak/abc_size'
  spec.metadata['changelog_uri'] = 'https://github.com/efurtak/abc_size/blob/master/CHANGELOG.md'

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'rainbow'
  spec.add_dependency 'rubocop'
  spec.add_dependency 'rubocop-ast'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
