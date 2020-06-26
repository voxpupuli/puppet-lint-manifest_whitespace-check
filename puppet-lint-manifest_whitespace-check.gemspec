# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = 'puppet-lint-manifest_whitespace-check'
  spec.version     = '0.1.10'
  spec.homepage    = 'https://github.com/kuleuven/puppet-lint-manifest_whitespace-check'
  spec.license     = 'MIT'
  spec.author      = 'Jo Vandeginste'
  spec.email       = 'jo.vandeginste@kuleuven.be'
  spec.files       = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.test_files  = Dir['spec/**/*']
  spec.summary     = 'A puppet-lint check to validate whitespace in manifests'
  spec.description = <<-EOF
    A new check for puppet-lint that validates generic whitespace issues in manifests.
  EOF

  spec.required_ruby_version = Gem::Requirement.new('>= 2.0')

  spec.add_dependency             'puppet-lint', '>= 1.0', '< 3.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'mime-types'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
end
