# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_closing_brace_before' do
  let(:closing_brace_msg) { 'there should be a single space or newline before a closing brace' }

  context 'with plus' do
    let(:code) do
      <<~CODE
        $my_images = { 'default' => {}}
      CODE
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'fixes a error' do
        expect(problems).to contain_fixed(closing_brace_msg)
      end

      it 'adds spaces' do
        expect(manifest).to eq(
          <<~CODE,
            $my_images = { 'default' => {} }
          CODE
        )
      end
    end
  end

  context 'with nested hash' do
    let(:code) do
      <<~CODE
        Hash $instances  = { 'localhost' => { 'url' => 'http://localhost/mod_status?auto' } },
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

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
          $value = [{ 'key' => 'value'}]
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
          $value7 = "x${server_facts['environment']}y"
          $value8 = {
            # nothing
          }

          if someothercondition { include ::otherclass}
          if somecondition {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
            class { 'example3':}
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 3 problems' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(closing_brace_msg).on_line(9).in_column(31)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'fixes a error' do
        expect(problems).to contain_fixed(closing_brace_msg)
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
              $value7 = "x${server_facts['environment']}y"
              $value8 = {
                # nothing
              }

              if someothercondition { include ::otherclass }
              if somecondition {
                class { 'example2':
                  param1  => 'value1',
                  require => File['somefile'],
                }
                class { 'example3': }
              }
            }
          CODE
        )
      end
    end
  end

  context 'with too many spaces' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) {
          $value = [{ 'key' => 'value'  }]
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },

          ]
          $value3 = myfunc($value1)
          $value4 = ['somekey'
          $value5 = []
          $value6 = { }
          $value7 = "x${server_facts['environment']}y"

          if someothercondition { include ::otherclass  }
          if somecondition {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
            class { 'example3':  }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 4 problems' do
        expect(problems).to have(4).problems
      end

      it 'creates a error' do
        expect(problems).to contain_error(closing_brace_msg).on_line(9).in_column(31)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'fixes a error' do
        expect(problems).to contain_fixed(closing_brace_msg)
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
              $value4 = ['somekey'
              $value5 = []
              $value6 = {}
              $value7 = "x${server_facts['environment']}y"

              if someothercondition { include ::otherclass }
              if somecondition {
                class { 'example2':
                  param1  => 'value1',
                  require => File['somefile'],
                }
                class { 'example3': }
              }
            }
          CODE
        )
      end
    end
  end

  context 'with too many newlines' do
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
          $value4 = ['somekey'
          $value5 = []
          $value6 = {

          }
          $value7 = "x${server_facts['environment']}y"

          if someothercondition { include ::otherclass }
          if somecondition {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],

            }

            class { 'example3': }

          }

        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 5 problems' do
        expect(problems).to have(5).problems
      end

      it 'creates a error' do
        expect(problems).to contain_error(closing_brace_msg).on_line(15).in_column(25)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'fixes a error' do
        expect(problems).to contain_fixed(closing_brace_msg)
      end

      it 'removes newlines' do
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
              $value4 = ['somekey'
              $value5 = []
              $value6 = {
              }
              $value7 = "x${server_facts['environment']}y"

              if someothercondition { include ::otherclass }
              if somecondition {
                class { 'example2':
                  param1  => 'value1',
                  require => File['somefile'],
                }

                class { 'example3': }
              }
            }
          CODE
        )
      end
    end
  end
end

describe 'manifest_whitespace_closing_brace_after' do
  let(:closing_brace_msg) do
    'there should be either a bracket, punctuation mark, closing quote or a newline after a closing brace, or whitespace and none of the aforementioned'
  end

  context 'with iterator' do
    let(:code) do
      <<~CODE
        ['ib0', 'ib1', 'ib2', 'ib3', 'pub', 'oob', '0', '184'].each |String $name| {
        }
      CODE
    end

    it 'detects no problems' do
      expect(problems).to be_empty
    end
  end

  context 'inline with a function after' do
    let(:code) do
      <<~CODE
        Hash({ $key => $return_value } )
      CODE
    end

    it 'detects 1 problem' do
      expect(problems).to have(1).problem
    end
  end

  context 'with spaces' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) {
          $value = [{ 'key' => 'value' } ]
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            } ,
          ]

          $value2bis = {
            'key' => 'value',
          } # this comment is fine

          $value3 = myfunc({} )
          $value4 = ['somekey']
          $value5 = []
          $value6 = {}
          $value7 = "x${server_facts['environment']}y"

          if someothercondition { include ::otherclass }
          if somecondition {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
            class { 'example3': }
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects 3 problems' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(closing_brace_msg).on_line(9).in_column(33)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'fixes a error' do
        expect(problems).to contain_fixed(closing_brace_msg)
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

              $value2bis = {
                'key' => 'value',
              } # this comment is fine

              $value3 = myfunc({})
              $value4 = ['somekey']
              $value5 = []
              $value6 = {}
              $value7 = "x${server_facts['environment']}y"

              if someothercondition { include ::otherclass }
              if somecondition {
                class { 'example2':
                  param1  => 'value1',
                  require => File['somefile'],
                }
                class { 'example3': }
              }
            }
          CODE
        )
      end
    end
  end
end
