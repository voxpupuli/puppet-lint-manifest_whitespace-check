# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_newline_beginning_of_file' do
  let(:single_beginning_of_file_msg) { 'there should not be a newline at the beginning of a manifest' }

  context 'with good example' do
    let(:code) do
      <<~CODE
        class example (



        ) {


        }
      CODE
    end

    it 'does not detect any problems' do
      expect(problems).to be_empty
    end
  end

  context 'with fix disabled' do
    context 'with 1 empty line at the beginning of a manifest' do
      let(:code) do
        <<~CODE

          class example {
          }
        CODE
      end

      it 'detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(single_beginning_of_file_msg).on_line(1).in_column(1)
      end
    end

    context 'with 3 empty lines at the beginning of a manifest' do
      let(:code) do
        <<~CODE



          class example {
          }
        CODE
      end

      it 'detects 3 problems' do
        expect(problems).to have(3).problem
      end

      it 'creates a error' do
        expect(problems).to contain_error(single_beginning_of_file_msg).on_line(1).in_column(1)
        expect(problems).to contain_error(single_beginning_of_file_msg).on_line(2).in_column(1)
        expect(problems).to contain_error(single_beginning_of_file_msg).on_line(3).in_column(1)
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'with 1 empty line at the beginning of a manifest' do
      let(:code) do
        <<~CODE

          class example {
          }
        CODE
      end

      it 'detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(single_beginning_of_file_msg).on_line(1).in_column(1)
      end

      it 'adds the final newline' do
        expect(manifest).to eq(
          <<~CODE,
            class example {
            }
          CODE
        )
      end
    end

    context 'with 3 empty lines at the beginning of a manifest' do
      let(:code) do
        <<~CODE



          class example {
          }
        CODE
      end

      it 'detects 3 problem' do
        expect(problems).to have(3).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(single_beginning_of_file_msg).on_line(1).in_column(1)
        expect(problems).to contain_fixed(single_beginning_of_file_msg).on_line(2).in_column(1)
        expect(problems).to contain_fixed(single_beginning_of_file_msg).on_line(3).in_column(1)
      end

      it 'adds the final newline' do
        expect(manifest).to eq(
          <<~CODE,
            class example {
            }
          CODE
        )
      end
    end
  end
end
