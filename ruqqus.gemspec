require_relative 'lib/ruqqus/version'

Gem::Specification.new do |spec|

  # Required specifications
  spec.name          = 'ruqqus'
  spec.version       = Ruqqus::VERSION
  spec.authors       = ['ForeverZer0']
  spec.email         = ['efreed09@gmail.com']
  spec.summary       = %q{A Ruby API implementation for Ruqqus, an open-source platform for online communities}
  spec.description   = %q{A Ruby API implementation for Ruqqus, an open-source platform for online communities, free of censorship and moderator abuse by design.}
  spec.homepage      = 'https://github.com/ForeverZer0/ruqqus'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # Metadata
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/ForeverZer0/ruqqus'
  spec.metadata['changelog_uri']     = 'https://github.com/ForeverZer0/ruqqus/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/gems/ruqqus'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/ForeverZer0/ruqqus/issues'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  # Register executables (none yet...)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_runtime_dependency('rest-client', '~> 2.1')

  spec.add_development_dependency('mechanize', '~> 2.7')
  spec.add_development_dependency('rake', '~> 13.0')
  spec.add_development_dependency('tty-prompt', '~> 0.22')
  spec.add_development_dependency('yard', '~> 0.9')
end
