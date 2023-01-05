# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

require 'puppet-lint'

PuppetLint::Plugins.load_spec_helper
