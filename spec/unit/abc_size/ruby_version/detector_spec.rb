# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe AbcSize::RubyVersion::Detector do
  describe '#call' do
    subject(:detector) { described_class.new.call }

    before do
      stub_const('AbcSize::RubyVersion::SUPPORTED_VERSIONS', [3.0])
    end

    context 'when detection succeeds' do
      it 'detects Ruby version' do
        allow(File).to receive(:read).and_return('3.0.3')

        expect(detector).to eq(3.0)
      end
    end

    context 'when detection fails' do
      it 'exit on Errno::ENOENT' do
        allow(File).to receive(:read).and_raise(Errno::ENOENT)

        expect { detector }.to raise_error(SystemExit)
      end

      it 'exit on EmptyFileError' do
        allow(File).to receive(:read).and_return('')

        expect { detector }.to raise_error(SystemExit)
      end

      it 'exit on UnknownFormatError' do
        allow(File).to receive(:read).and_return('ruby-3.0.3')

        expect { detector }.to raise_error(SystemExit)
      end

      it 'exit on UnsupportedVersionError' do
        allow(File).to receive(:read).and_return('2.7')

        expect { detector }.to raise_error(SystemExit)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
