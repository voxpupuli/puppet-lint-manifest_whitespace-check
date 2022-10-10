# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_closing_bracket_before' do
  let(:closing_bracket_msg) { 'there should be no whitespace or a single newline before a closing bracket' }

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
      it 'should detect 0 problems' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with too many spaces' do
    let(:code) do
      <<~EOF
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) {
          $value = [{ 'key' => 'value' }  ]
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            },

          ]
          $value3 = myfunc($value1)
          $value4 = ['somekey' ]
          $value5 = [ ]
          $value6 = {}
          $value7 = "x${server_facts['environment']}y"

          if somecondition {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile' ],
            }
          }
        }
      EOF
    end

    context 'with fix disabled' do
      it 'should detect 5 problems' do
        expect(problems).to have(5).problems
      end

      it 'should create a error' do
        expect(problems).to contain_error(closing_bracket_msg).on_line(9).in_column(33)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'should detect 5 problems' do
        expect(problems).to have(5).problems
      end

      it 'should fix a error' do
        expect(problems).to contain_fixed(closing_bracket_msg)
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
              $value7 = "x${server_facts['environment']}y"

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

describe 'manifest_whitespace_closing_bracket_after' do
  let(:closing_bracket_msg) {
    'there should be either a bracket, punctuation mark, closing quote or a newline after a closing bracket, or whitespace and none of the aforementioned'
  }

  context 'with many brackets' do
    let(:code) do
      <<~EOF
        ensure_packages($spaceweather::packages, { require => Class['Mongodb::Globals'] })
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with iterator' do
    let(:code) do
      <<~EOF
        ['ib0', 'ib1', 'ib2', 'ib3', 'pub', 'oob', '0', '184'].each |String $name| {
        }

        ['ib0', 'ib1', 'ib2', 'ib3', 'pub', 'oob', '0', '184'].each |String $name| {
        }
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with spaces' do
    let(:code) do
      <<~EOF
        # example
        #
        # Main class, includes all other classes.
        #

        class example (
          String $content,
        ) {
          $value = { 'key' => ['value'] }
          $value2 = [
            {
              'key' => 'value1',
            },
            {
              'key' => 'value2',
            } ,
          ]

          $value2bis = [
            'value',
          ] # this comment is fine

          $value3 = myfunc([] )
          $value4 = ['somekey']
          $value5 = []
          $value6 = {}
          $value7 = "x${server_facts['environment']}y"

          if somecondition {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'] ,
            }
            class { 'example3': }
          }
          if someothercondition { include ::otherclass }

          package { ['package1', 'package2']:
            ensure   => installed,
          }
        }
      EOF
    end

    context 'with fix disabled' do
      it 'should detect 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a error' do
        expect(problems).to contain_error(closing_bracket_msg).on_line(23).in_column(22)
      end
    end

    context 'with fix enabled' do
      before do
        PuppetLint.configuration.fix = true
      end

      after do
        PuppetLint.configuration.fix = false
      end

      it 'should fix a error' do
        expect(problems).to contain_fixed(closing_bracket_msg)
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
              $value = { 'key' => ['value'] }
              $value2 = [
                {
                  'key' => 'value1',
                },
                {
                  'key' => 'value2',
                } ,
              ]

              $value2bis = [
                'value',
              ] # this comment is fine

              $value3 = myfunc([])
              $value4 = ['somekey']
              $value5 = []
              $value6 = {}
              $value7 = "x${server_facts['environment']}y"

              if somecondition {
                class { 'example2':
                  param1  => 'value1',
                  require => File['somefile'],
                }
                class { 'example3': }
              }
              if someothercondition { include ::otherclass }

              package { ['package1', 'package2']:
                ensure   => installed,
              }
            }
          EOF
        )
      end
    end
  end

  context 'inside heredoc' do
    describe 'issue10 example' do
      let(:code) do
        <<~CODE
          file { '/tmp/test':
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            content => Sensitive(@("EOF")),
            # hostname:port:database:username:password
            127.0.0.1:5432:aos:${variable}:${hash['password']}
            localhost:5432:aos:${variable}:${hash['password']}
            | EOF
          }
        CODE
      end

      it 'should detect no problems' do
        expect(problems).to be_empty
      end
    end

    describe 'interpolated hash key in middle of line' do
      let(:code) do
        <<~CODE
          $content = @("EOF")
            somestring:${foo['bar']}:more
            more stuff
            | EOF
          # more puppet code follows
        CODE
      end

      it 'should detect no problems' do
        expect(problems).to be_empty
      end

      context 'with unwanted whitespace' do
        let(:code) do
          <<~CODE
            $content = @("EOF")
              somestring:${foo['bar'] }:more
              more stuff
              | EOF
            # more puppet code follows
          CODE
        end

        it 'should detect 1 problem' do
          expect(problems).to have(1).problem
        end
      end
    end

    describe 'interpolated hash key at end of line' do
      let(:code) do
        <<~CODE
          $content = @("EOF")
            somestring:${foo['bar']}
            more stuff
            | EOF
          # more puppet code follows
        CODE
      end

      it 'should detect no problems' do
        expect(problems).to be_empty
      end

      context 'with unwanted whitespace' do
        let(:code) do
          <<~CODE
            $content = @("EOF")
              somestring:${foo['bar'] }
              more stuff
              | EOF
            # more puppet code follows
          CODE
        end

        it 'should detect 1 problem' do
          expect(problems).to have(1).problem
        end
      end
    end

    describe 'interpolated hash key at end of heredoc' do
      let(:code) do
        <<~CODE
          $content = @("EOF")
            # Some random heredoc preamble
            somestring:${foo['bar']}
            | EOF
          # more puppet code follows
        CODE
      end

      it 'should detect no problems' do
        expect(problems).to be_empty
      end

      context 'with unwanted whitespace' do
        let(:code) do
          <<~CODE
            $content = @("EOF")
              # Some random heredoc preamble
              somestring:${foo['bar'] }
              | EOF
            # more puppet code follows
          CODE
        end

        it 'should detect 1 problem' do
          expect(problems).to have(1).problem
        end
      end
    end
  end
end
