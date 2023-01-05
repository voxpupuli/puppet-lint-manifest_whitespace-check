# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_inherits_name_single_space_before' do
  let(:single_space_msg) { 'there should be a single space between the inherits statement and the name' }

  context 'with two spaces' do
    let(:code) do
      <<~CODE
        # example
        #
        # Main class, includes all other classes.
        #

        class example inherits  other::example {
          class { 'example2':
            param1 => 'value1',
          }
        }
      CODE
    end

    context 'with fix disabled' do
      it 'detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(single_space_msg).on_line(6).in_column(23)
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
            # example
            #
            # Main class, includes all other classes.
            #

            class example inherits other::example {
              class { 'example2':
                param1 => 'value1',
              }
            }
          CODE
        )
      end
    end
  end
end
