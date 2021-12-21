# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength, RSpec/NestedGroups
RSpec.describe AbcSize::RubyVersion::Picker do
  describe '#call' do
    subject(:picker) { described_class.new(parameters).call }

    before do
      stub_const('AbcSize::RubyVersion::SUPPORTED_VERSIONS', [3.0])
    end

    context 'when picking succeeds' do
      let(:parameters) { ['-r', 3.0] }

      it 'picks Ruby version' do
        expect(picker).to eq(3.0)
      end
    end

    context 'when picking fails' do
      context 'when unsupported version given' do
        let(:parameters) { ['-r', 2.7] }

        it 'exit on UnsupportedVersionError' do
          expect { picker }.to raise_error(SystemExit)
        end
      end

      context 'when parameter without value given' do
        let(:parameters) { ['-r'] }

        it 'exit on UnsupportedVersionError' do
          expect { picker }.to raise_error(SystemExit)
        end
      end

      context 'when no parameters given' do
        let(:parameters) { [] }

        it 'return nil' do
          expect(picker).to eq(nil)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength, RSpec/NestedGroups
