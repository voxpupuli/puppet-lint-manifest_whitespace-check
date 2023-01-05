# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_opening_bracket_before' do
  let(:opening_bracket_msg) { 'there should be a single space before an opening bracket' }

  context 'inside heredoc' do
    let(:code) do
      <<~CODE
        class test::heredoc {
          $unsupported = @("MESSAGE"/L)
            This does not support ${facts['os']['name']} ${$facts['os']['release']['major']}; \
            see ${support_urls['supported_platforms']} for more information\
            | MESSAGE

          fail($unsupported)
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'as value in an lambda' do
    let(:code) do
      <<~CODE
        $result = assert_type(Array, $some_value) |$expected, $actual| { [] }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with iterator' do
    let(:code) do
      <<~CODE
        {
          if condition {
          }

          ['ib0', 'ib1', 'ib2', 'ib3', 'pub', 'oob', '0', '184'].each |String $name| {
          }
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with array key in interpolation' do
    let(:code) do
      <<~CODE
        "${my_array['keyname']}"
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with multiline iterator' do
    let(:code) do
      <<~CODE
        include my::class

        [
          'a',
          'b',
        ].each |$i| { }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with no spaces' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
          Optional[String] $some_other_content,
          Array $var = lookup('foo::bar', Array, undef, [])
        ) {
          if $fact["${var}"] != $var2.keys[0] {
            # noop
          }

          if fact["${var}"] != $var2.keys[0] {
            # noop
          }
          $variable_customfact = $facts['customfact_name'][$variable]

          $value = [{ 'key' => 'value' }]
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },
          ]
          $value3 = myfunc($value1)
          $value4 = ['somekey']
          $value5 = []
          $value6 = {}

          if somecondition {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
            package { ['pack1', 'pack2']:
              ensure => present,
            }
            package {
              ['pack3', 'pack4']:
                ensure => present;
              ['pack5', 'pack6']:
                ensure => present;
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 0 problems' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with resource inline' do
    let(:code) do
      <<~CODE
        package { ['pack1', 'pack2']:
          ensure => present,
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 0 problems' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with resource next line' do
    let(:code) do
      <<~CODE
        package {
          ['pack3', 'pack4']:
            ensure => present;
          ['pack5', 'pack6']:
            ensure => present;
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 0 problems' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with two spaces' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        )  {
          $value =  [{ 'key' => 'value' }]
          $value2 =  [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },
          ]
          $value3 = myfunc($value1)

          if somecondition  {
            class  { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a 2 problems' do
        expect(problems).to have(2).problems
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_bracket_msg).on_line(9).in_column(13)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects a 2 problems' do
        expect(problems).to have(2).problems
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_bracket_msg)
      end

      it 'removes a space' do
        expect(manifest).to eq(
          <<~CODE,
            # example
            #
            # Main class, includes all other classes.
            #

            class example (
              String $content,
            )  {
              $value = [{ 'key' => 'value' }]
              $value2 = [
                {
                  'key' => 'value1',
                },
                {
                  'key' => 'value2',
                },
              ]
              $value3 = myfunc($value1)

              if somecondition  {
                class  { 'example2':
                  param1  => 'value1',
                  require => File['somefile'],
                }
              }
            }
          CODE
        )
      end
    end
  end

  context 'with newline' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        )
        {
          $value = [{ 'key' => 'value' }]
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },
          ]
          $value3 = myfunc($value1)

          if somecondition
          {
            class
            { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a no problems' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with comment 1' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) # some generic comment
        {
          $value = [{ 'key' => 'value' }]
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },
          ]
          $value3 = myfunc($value1)

          if somecondition # some generic comment
          {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a no problems' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with comment 2' do
    let(:code) do
      <<~CODE
        {
          # some generic comment
          ['some', 'values']
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end
end

describe 'manifest_whitespace_opening_bracket_after' do
  let(:opening_bracket_msg) { 'there should be no whitespace or a single newline after an opening bracket' }

  context 'with iterator' do
    let(:code) do
      <<~CODE
        ['ib0', 'ib1', 'ib2', 'ib3', 'pub', 'oob', '0', '184'].each |String $name| {
        }

        ['ib0', 'ib1', 'ib2', 'ib3', 'pub', 'oob', '0', '184'].each |String $name| {
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with a single space' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) {
          $value = [ {  'key' => 'value' }]
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },
          ]
          $value3 = myfunc($value1)
          $value4 = [ 'somekey']
          $value5 = [ ]
          $value6 = {}

          if somecondition {
            class {  'example2':
              param1  => 'value1',
              require => File[ 'somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 4 problems' do
        expect(problems).to have(4).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_bracket_msg).on_line(9).in_column(13)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_bracket_msg)
      end

      it 'adds spaces' do
        expect(manifest).to eq(
          <<~CODE,
            # example
            #
            # Main class, includes all other classes.
            #

            class example (
              String $content,
            ) {
              $value = [{  'key' => 'value' }]
              $value2 = [
                {
                  'key' => 'value1',
                },
                {
                  'key' => 'value2',
                },
              ]
              $value3 = myfunc($value1)
              $value4 = ['somekey']
              $value5 = []
              $value6 = {}

              if somecondition {
                class {  'example2':
                  param1  => 'value1',
                  require => File['somefile'],
                }
              }
            }
          CODE
        )
      end
    end
  end

  context 'with no spaces' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) {
          $value = [{'key' => 'value' }]
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },
          ]
          $value3 = myfunc($value1)

          if somecondition {
            class {'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 0 problems' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with two newlines' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) {

          $value = [{ 'key' => 'value' }]
          $value2 = [

            {

              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },
          ]
          $value3 = myfunc($value1)

          if somecondition {

            class {

              'example2':
                param1  => 'value1',
                require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 1 problems' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_bracket_msg).on_line(12).in_column(1)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects 1 problems' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_bracket_msg)
      end

      it 'adds spaces' do
        expect(manifest).to eq(
          <<~CODE,
            # example
            #
            # Main class, includes all other classes.
            #

            class example (
              String $content,
            ) {

              $value = [{ 'key' => 'value' }]
              $value2 = [
                {

                  'key' => 'value1',
                },
                {
                  'key' => 'value2',
                },
              ]
              $value3 = myfunc($value1)

              if somecondition {

                class {

                  'example2':
                    param1  => 'value1',
                    require => File['somefile'],
                }
              }
            }
          CODE
        )
      end
    end
  end
end
