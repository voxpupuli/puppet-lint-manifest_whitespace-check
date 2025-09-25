# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = 'puppet-lint-manifest_whitespace-check'
  spec.version     = '2.0.0'
  spec.homepage    = 'https://github.com/voxpupuli/puppet-lint-manifest_whitespace-check'
  spec.license     = 'MIT'
  spec.author      = ['Jo Vandeginste', 'Vox Pupuli']
  spec.email       = 'voxpupuli@groups.io'
  spec.files       = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.summary     = 'A puppet-lint check to validate whitespace in manifests'
  spec.description = 'A new check for puppet-lint that validates generic whitespace issues in manifests.'

  spec.required_ruby_version = '>= 3.2'

  spec.add_dependency 'puppet-lint', '~> 5.1'
end
