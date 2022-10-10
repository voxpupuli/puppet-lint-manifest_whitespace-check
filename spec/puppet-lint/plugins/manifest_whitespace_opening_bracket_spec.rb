# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_opening_bracket_before' do
  let(:opening_bracket_msg) { 'there should be a single space before an opening bracket' }

  context 'with comment' do
    let(:code) do
      <<~EOF
        {
          # some generic comment
          ['some', 'values']
        }
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with iterator' do
    let(:code) do
      <<~EOF
        {
          if condition {
          }

          ['ib0', 'ib1', 'ib2', 'ib3', 'pub', 'oob', '0', '184'].each |String $name| {
          }
        }
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
    end
  end

  context 'with multiline iterator' do
    let(:code) do
      <<~EOF
        include my::class

        [
          'a',
          'b',
        ].each |$i| { }
      EOF
    end

    it 'should detect no problems' do
      expect(problems).to be_empty
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
          Optional[String] $some_other_content,
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

          if somecondition {
            class { 'example2':
              param1  => 'value1',
              require => File['somefile'],
            }
            package { ['pack1', 'pack2']:
              ensure => present,
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect a 2 problems' do
        expect(problems).to have(2).problems
      end

      it 'should create a error' do
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

      it 'should detect a 2 problems' do
        expect(problems).to have(2).problems
      end

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_bracket_msg)
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
      it 'should detect a no problems' do
        expect(problems).to be_empty
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
      it 'should detect a no problems' do
        expect(problems).to be_empty
      end
    end
  end
end

describe 'manifest_whitespace_opening_bracket_after' do
  let(:opening_bracket_msg) { 'there should be no whitespace or a single newline after an opening bracket' }

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

  context 'with a single space' do
    let(:code) do
      <<~EOF
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
      EOF
    end

    context 'with fix disabled' do
      it 'should detect 4 problems' do
        expect(problems).to have(4).problem
      end

      it 'should create a error' do
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

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_bracket_msg)
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
      it 'should detect 0 problems' do
        expect(problems).to be_empty
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
      it 'should detect 1 problems' do
        expect(problems).to have(1).problem
      end

      it 'should create a error' do
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

      it 'should detect 1 problems' do
        expect(problems).to have(1).problem
      end

      it 'should create a error' do
        expect(problems).to contain_fixed(opening_bracket_msg)
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
