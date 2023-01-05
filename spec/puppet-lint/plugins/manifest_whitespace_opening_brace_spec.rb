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
      <<~EOF
        $value7 = {
          # nothing
        }
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inside, inline with function' do
    let(:code) do
      <<~EOF
        $sssd_config = {
        ▏ 'sssd' => merge($config, {
        ▏ ▏ ▏ 'domains'  => $domains,
        ▏ ▏ ▏ 'services' => 'nss,pam',
        ▏ }),
        }
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inside interpolation' do
    let(:code) do
      <<~EOF
        my_define { "foo-${myvar}": }
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inline with a function before' do
    let(:code) do
      <<~EOF
        Hash( { $key => $return_value })
      EOF
    end

    it 'should detect 1 problem' do
      expect(problems).to have(1).problem
    end
  end

  context 'inline with a function' do
    let(:code) do
      <<~EOF
        Hash({ $key => $return_value })
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inside a function' do
    let(:code) do
      <<~EOF
        $my_var = lookup(
          {
            'name'          => 'my_module::my_var',
            'merge'         => 'deep',
            'value_type'    => Array[Hash],
            'default_value' => [],
          }
        )
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with cases' do
    let(:code) do
      <<~EOF
        case $facts['kernel'] {
          'OpenBSD': { $has_wordexp = false }
          default:   { $has_wordexp = true }
        }
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with class no spaces' do
    let(:code) do
      <<~EOF
        class example{
          # some generic comment
        }
      EOF
    end

    context 'with fix disabled' do
      it 'should detect a problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a error' do
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

      it 'should add a space' do
        expect(manifest).to eq(
          <<~EOF,
            class example {
              # some generic comment
            }
          EOF
        )
      end
    end
  end

  context 'with no spaces' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect three problems' do
        expect(problems).to have(3).problem
      end

      it 'should create a error' do
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

      it 'should detect three problems' do
        expect(problems).to have(3).problem
      end

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
      end

      it 'should add spaces' do
        expect(manifest).to eq(
          <<~EOF,
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
          EOF
        )
      end
    end
  end

  context 'with two spaces' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect a single problem' do
        expect(problems).to have(3).problem
      end

      it 'should create a error' do
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

      it 'should detect a single problem' do
        expect(problems).to have(3).problem
      end

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
      end

      it 'should remove a space' do
        expect(manifest).to eq(
          <<~EOF,
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
          EOF
        )
      end
    end
  end

  context 'with newline' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect a single problem' do
        expect(problems).to have(3).problem
      end

      it 'should create a error' do
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

      it 'should detect a single problem' do
        expect(problems).to have(3).problem
      end

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
      end

      it 'should fix the newline' do
        expect(manifest).to eq(
          <<~EOF,
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
          EOF
        )
      end
    end
  end

  context 'with comment' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect a single problem' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with good inherits' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect no problem' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with bad inherits' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a error' do
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

      it 'should detect a missing space' do
        expect(problems).to have(1).problem
      end

      it 'should add the space' do
        expect(manifest).to eq(
          <<~EOF,
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
          EOF
        )
      end
    end
  end
end

describe 'manifest_whitespace_opening_brace_after' do
  let(:opening_brace_msg) { 'there should be a single space or single newline after an opening brace' }

  context 'with two spaces' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a error' do
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

      it 'should detect 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
      end

      it 'should add spaces' do
        expect(manifest).to eq(
          <<~EOF,
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
          EOF
        )
      end
    end
  end

  context 'with no spaces' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a error' do
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

      it 'should detect 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
      end

      it 'should add spaces' do
        expect(manifest).to eq(
          <<~EOF,
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
          EOF
        )
      end
    end
  end

  context 'with two newlines' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect 4 problems' do
        expect(problems).to have(4).problem
      end

      it 'should create a error' do
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

      it 'should detect 4 problems' do
        expect(problems).to have(4).problem
      end

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_brace_msg)
      end

      it 'should add spaces' do
        expect(manifest).to eq(
          <<~EOF,
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
          EOF
        )
      end
    end
  end
end
