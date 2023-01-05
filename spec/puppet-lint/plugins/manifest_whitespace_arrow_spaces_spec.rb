# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_arrows_single_space_after' do
  let(:single_space_msg) { 'there should be a single space after an arrow' }

  context 'with two spaces' do
    let(:code) do
      <<~CODE
        class { 'example2':
          param1 =>  'value1',
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(single_space_msg).on_line(2).in_column(12)
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
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(single_space_msg)
      end

      it 'fixes the space' do
        expect(manifest).to eq(
          <<~CODE,
            class { 'example2':
              param1 => 'value1',
            }
          CODE
        )
      end
    end
  end

  context 'with no spaces' do
    let(:code) do
      <<~CODE
        class { 'example2':
          param1 =>'value1',
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(single_space_msg).on_line(2).in_column(12)
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
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(single_space_msg)
      end

      it 'fixes the space' do
        expect(manifest).to eq(
          <<~CODE,
            class { 'example2':
              param1 => 'value1',
            }
          CODE
        )
      end
    end
  end

  context 'with string as space' do
    let(:code) do
      <<~CODE
        class { 'example2':
          param1 =>' ',
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(single_space_msg).on_line(2).in_column(12)
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
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(single_space_msg)
      end

      it 'fixes the space' do
        expect(manifest).to eq(
          <<~CODE,
            class { 'example2':
              param1 => ' ',
            }
          CODE
        )
      end
    end
  end

  context 'many resources' do
    let(:code) do
      <<~CODE
        class { 'example2':
          param1 =>'value1',
          param2 => 'value2',
          param3 =>   'value3',
          param4 =>  'value4',
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a single problem' do
        expect(problems).to have(3).problems
      end

      it 'creates a error' do
        expect(problems).to contain_error(single_space_msg).on_line(2).in_column(12)
        expect(problems).to contain_error(single_space_msg).on_line(4).in_column(12)
        expect(problems).to contain_error(single_space_msg).on_line(5).in_column(12)
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

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(single_space_msg)
      end

      it 'fixes the space' do
        expect(manifest).to eq(
          <<~CODE,
            class { 'example2':
              param1 => 'value1',
              param2 => 'value2',
              param3 => 'value3',
              param4 => 'value4',
            }
          CODE
        )
      end
    end
  end

  context 'valid cases' do
    context 'correct arrow' do
      let(:code) do
        <<~CODE
          class { 'example2':
            param1 => 'value1',
          }
        CODE
      end

      it 'detects a no problem' do
        expect(problems).to be_empty
      end
    end

    context 'in a string' do
      let(:code) do
        <<~CODE
          "param1 =>    'value1'",
        CODE
      end

      it 'detects a no problem' do
        expect(problems).to be_empty
      end
    end

    context 'in a heredoc' do
      let(:code) do
        <<~CODE
          $data = @("DATA"/L)
            param1 =>    'value1',
            | DATA
        CODE
      end

      it 'detects a no problem' do
        expect(problems).to be_empty
      end
    end
  end
end
