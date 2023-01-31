# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_opening_brace_before' do
  let(:opening_brace_msg) { 'there should be a single space before an opening brace' }

  context 'parameters without space' do
    let(:code) do
      <<~CODE
        $foo = lookup('foo::bar',Hash,'first',{})
      CODE
    end

    it 'detects a problem' do
      expect(problems).not_to be_empty
    end
  end

  context 'with comment only' do
    let(:code) do
      <<~CODE
        $value7 = {
          # nothing
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with an iterator' do
    let(:code) do
      <<~CODE
        $slave_ifnames = $bonds.reduce({}) |$l, $i| {
          $l + split($i['attached_devices'], /,/).reduce({}) |$sl, $d| { $sl + { $d => $i['identifier'] } }
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inside, inline with function' do
    let(:code) do
      <<~CODE
        $sssd_config = {
          'sssd' => merge($config, {
             'domains'  => $domains,
             'services' => 'nss,pam',
          }),
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inside interpolation' do
    let(:code) do
      <<~CODE
        my_define { "foo-${myvar}": }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inline with a function before' do
    let(:code) do
      <<~CODE
        Hash( { $key => $return_value })
      CODE
    end

    it 'detects 1 problem' do
      expect(problems).to have(1).problem
    end
  end

  context 'inline with a function' do
    let(:code) do
      <<~CODE
        Hash({ $key => $return_value })
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inside a function' do
    let(:code) do
      <<~CODE
        $my_var = lookup(
          {
            'name'          => 'my_module::my_var',
            'merge'         => 'deep',
            'value_type'    => Array[Hash],
            'default_value' => [],
          }
        )
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with cases' do
    let(:code) do
      <<~CODE
        case $facts['kernel'] {
          'OpenBSD': { $has_wordexp = false }
          default:   { $has_wordexp = true }
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with class no spaces' do
    let(:code) do
      <<~CODE
        class example{
          # some generic comment
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_brace_msg).on_line(1).in_column(14)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'adds a space' do
        expect(manifest).to eq(
          <<~CODE,
            class example {
              # some generic comment
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
        ){
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
          $value7 = {
            # nothing
          }

          if somecondition{
            class{ 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects three problems' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_brace_msg).on_line(8).in_column(2)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects three problems' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
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
              $value4 = ['somekey']
              $value5 = []
              $value6 = {}
              $value7 = {
                # nothing
              }

              if somecondition {
                class { 'example2':
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
    end

    context 'with fix disabled' do
      it 'detects a single problem' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_brace_msg).on_line(8).in_column(4)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects a single problem' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
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
                class { 'example2':
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
      it 'detects a single problem' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_brace_msg).on_line(9).in_column(1)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects a single problem' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
      end

      it 'fixes the newline' do
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
                class { 'example2':
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

  context 'with comment' do
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
      it 'detects a single problem' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with good inherits' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) inherits otherclass {
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
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects no problem' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with bad inherits' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) inherits otherclass{
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
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_brace_msg).on_line(8).in_column(22)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects a missing space' do
        expect(problems).to have(1).problem
      end

      it 'adds the space' do
        expect(manifest).to eq(
          <<~CODE,
            # example
            #
            # Main class, includes all other classes.
            #

            class example (
              String $content,
            ) inherits otherclass {
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
                class { 'example2':
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

describe 'manifest_whitespace_opening_brace_after' do
  let(:opening_brace_msg) { 'there should be a single space or single newline after an opening brace' }

  context 'with two spaces' do
    let(:code) do
      <<~CODE
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
          $value7 = {
            # nothing
          }

          if somecondition {
            class {  'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_brace_msg).on_line(9).in_column(14)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
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
              $value4 = ['somekey']
              $value5 = []
              $value6 = {}
              $value7 = {
                # nothing
              }

              if somecondition {
                class { 'example2':
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
      it 'detects 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_brace_msg).on_line(9).in_column(14)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
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
                class { 'example2':
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
      it 'detects 4 problems' do
        expect(problems).to have(4).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(opening_brace_msg).on_line(9).in_column(1)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'detects 4 problems' do
        expect(problems).to have(4).problem
      end

      it 'creates a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
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
