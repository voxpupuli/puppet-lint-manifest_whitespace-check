# puppet-lint manifest whitespace check

[![License](https://img.shields.io/github/license/voxpupuli/puppet-lint-manifest_whitespace-check.svg)](https://github.com/voxpupuli/puppet-lint-manifest_whitespace-check/blob/master/LICENSE)
[![Test](https://github.com/voxpupuli/puppet-lint-manifest_whitespace-check/actions/workflows/test.yml/badge.svg)](https://github.com/voxpupuli/puppet-lint-manifest_whitespace-check/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/voxpupuli/puppet-lint-manifest_whitespace-check/branch/master/graph/badge.svg?token=Mypkl78hvK)](https://codecov.io/gh/voxpupuli/puppet-lint-manifest_whitespace-check)
[![Release](https://github.com/voxpupuli/puppet-lint-manifest_whitespace-check/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-lint-manifest_whitespace-check/actions/workflows/release.yml)
[![RubyGem Version](https://img.shields.io/gem/v/puppet-lint-manifest_whitespace-check.svg)](https://rubygems.org/gems/puppet-lint-manifest_whitespace-check)
[![RubyGem Downloads](https://img.shields.io/gem/dt/puppet-lint-manifest_whitespace-check.svg)](https://rubygems.org/gems/puppet-lint-manifest_whitespace-check)
[![Donated by Jo Vandeginste](https://img.shields.io/badge/donated%20by-Jo%20Vandeginste-fb7047.svg)](#copyright)

Adds a new puppet-lint check to verify a number of whitespace issues (newlines etc.)

These checks are very opinionated.

**--fix support: Yes**

## Installation

To use this plugin, add the following line to the Gemfile in your Puppet code
base and run `bundle install`.

```ruby
gem 'puppet-lint-manifest_whitespace-check'
```

## Usage

This plugin provides a number of new checks to `puppet-lint`.

### manifest_whitespace_opening_bracket_after

> There should be a single space or single newline after an opening curly brace

Exceptions: other brackets or comma's

### manifest_whitespace_opening_bracket_before

> There should be a single space before an opening bracket

Exceptions: other brackets

Good examples:

```puppet
class myclass (
  # the parameters
) {
  # the body
}

class myclass {
  # the body
}

class myclass {
  $value = [{ 'key' => 'value' }]

  if somecondition {
    class { 'someclass': }
  }
}
```

Bad examples:

```puppet
class myclass (
  # the parameters
)
{
  # the body
}

class myclass (
  # the parameters
){
  # the body
}

class myclass
{
  # the body
}

class myclass {
  if somecondition{
    class{ 'someclass': }
  }
}
```

### manifest_whitespace_missing_newline_end_of_file

> There should be a single newline at the end of a manifest.

Not zero, not two or more. Be advised: this single newline is implicit at the end of your last line of code. This check does not add a single empty line!

### manifest_whitespace_double_newline_end_of_file

> There should be a single newline at the end of a manifest.

Not zero, not two or more. Be advised: this single newline is implicit at the end of your last line of code. This check does not add a single empty line!

### manifest_whitespace_arrows_single_space_after

> There should be a single space after an arrow.

When you list resource parameters or build a hash, you usually use arrow operators (`=>`). There are checks that make sure your arrows are aligned, but this check will ensure the number of spaces after your arrows is consistently 1.

### manifest_whitespace_newline_beginning_of_file

> There should not be a newline at the beginning of a manifest.

There should not be empty lines at the beginning of your file.

### manifest_whitespace_class_name_single_space_before

> There should be a single space between the class or defined resource statement and the name.

Good examples:

```puppet
class myclass (
  # the parameters
) {
  # the body
}

class myclass {
  # the body
}
```

Bad example:

```puppet
class  myclass (
  # the parameters
) {
  # the body
}
```

### manifest_whitespace_class_name_single_space_after

> There should be a single space between the class or resource name and the first brace.

Good examples:

```puppet
class myclass (
  # the parameters
) {
  # the body
}

class myclass {
  # the body
}
```

Bad example:

```puppet
class myclass(
  # the parameters
){
  # the body
}

class myclass  (
  # the parameters
){
  # the body
}

class myclass
(
  # the parameters
){
  # the body
}
```

## License

This project is licensed unter MIT

## Transfer Notice

This plugin was originally maintained by [Jo Vandeginste](https://github.com/jovandeginste).
The maintainer preferred that [Vox Pupuli](https://voxpupuli.org/) take ownership of the module for future improvement and maintenance.

## Release information

To make a new release, please do:
* update the version in the gemspec file
* Install gems with `bundle install --with release --path .vendor`
* generate the changelog with `bundle exec rake changelog`
* Check if the new version matches the closed issues/PRs in the changelog
* Create a PR with it
* After it got merged, push a tag. GitHub actions will do the actual release to rubygems and GitHub Packages
