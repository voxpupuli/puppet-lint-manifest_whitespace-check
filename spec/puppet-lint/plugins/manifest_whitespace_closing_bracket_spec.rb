# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_closing_bracket_before' do
  let(:closing_bracket_msg) { 'there should be no whitespace or a single newline before a closing bracket' }

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
      CODE
    end

    context 'with fix disabled' do
      it 'detects 0 problems' do
        expect(problems).to be_empty
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
      CODE
    end

    context 'with fix disabled' do
      it 'detects 5 problems' do
        expect(problems).to have(5).problems
      end

      it 'creates a error' do
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

      it 'detects 5 problems' do
        expect(problems).to have(5).problems
      end

      it 'fixes a error' do
        expect(problems).to contain_fixed(closing_bracket_msg)
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

describe 'manifest_whitespace_closing_bracket_after' do
  let(:closing_bracket_msg) do
    'there should be either a bracket, punctuation mark, closing quote or a newline after a closing bracket, or whitespace and none of the aforementioned'
  end

  context 'with many brackets' do
    let(:code) do
      <<~CODE
        ensure_packages($spaceweather::packages, { require => Class['Mongodb::Globals'] })
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
      CODE
    end

    context 'with fix disabled' do
      it 'detects 2 problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a error' do
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

      it 'fixes a error' do
        expect(problems).to contain_fixed(closing_bracket_msg)
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
          CODE
        )
      end
    end
  end

  context 'inside heredoc 1' do
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

  context 'inside heredoc 2' do
    describe 'issue10 example' do
      let(:code) do
        <<~CODE
          file { '/tmp/test':
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            content => Sensitive(@("CODE")),
            # hostname:port:database:username:password
            127.0.0.1:5432:aos:${variable}:${hash['password']}
            localhost:5432:aos:${variable}:${hash['password']}
            | CODE
          }
        CODE
      end

      it 'detects no problems' do
        expect(problems).to be_empty
      end
    end

    describe 'interpolated hash key in middle of line' do
      let(:code) do
        <<~CODE
          $content = @("CODE")
            somestring:${foo['bar']}:more
            more stuff
            | CODE
          # more puppet code follows
        CODE
      end

      it 'detects no problems' do
        expect(problems).to be_empty
      end

      context 'with unwanted whitespace' do
        let(:code) do
          <<~CODE
            $content = @("CODE")
              somestring:${foo['bar'] }:more
              more stuff
              | CODE
            # more puppet code follows
          CODE
        end

        it 'detects 1 problem' do
          expect(problems).to have(1).problem
        end
      end
    end

    describe 'interpolated hash key at end of line' do
      let(:code) do
        <<~CODE
          $content = @("CODE")
            somestring:${foo['bar']}
            more stuff
            | CODE
          # more puppet code follows
        CODE
      end

      it 'detects no problems' do
        expect(problems).to be_empty
      end

      context 'with unwanted whitespace' do
        let(:code) do
          <<~CODE
            $content = @("CODE")
              somestring:${foo['bar'] }
              more stuff
              | CODE
            # more puppet code follows
          CODE
        end

        it 'detects 1 problem' do
          expect(problems).to have(1).problem
        end
      end
    end

    describe 'interpolated hash key at end of heredoc' do
      let(:code) do
        <<~CODE
          $content = @("CODE")
            # Some random heredoc preamble
            somestring:${foo['bar']}
            | CODE
          # more puppet code follows
        CODE
      end

      it 'detects no problems' do
        expect(problems).to be_empty
      end

      context 'with unwanted whitespace' do
        let(:code) do
          <<~CODE
            $content = @("CODE")
              # Some random heredoc preamble
              somestring:${foo['bar'] }
              | CODE
            # more puppet code follows
          CODE
        end

        it 'detects 1 problem' do
          expect(problems).to have(1).problem
        end
      end
    end
  end
end
