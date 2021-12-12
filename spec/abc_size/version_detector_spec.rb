# frozen_string_literal: true

RSpec.describe AbcSize::VersionDetector do
  describe '#call' do
    let(:call) { described_class.new(path).call }

    context 'when relative path given, so detection is enabled' do
      let(:path) { 'some/relative/path/to/file.rb' }

      it 'return proper version_info hash - when Not detected .ruby-version file!' do
        expect(File).to receive(:read).and_raise(Errno::ENOENT)

        expect(call).to eq({
          supported: described_class::SUPPORTED_VERSIONS,
          default: described_class::DEFAULT_VERSION,
          detected: nil,
          other: {
            relative_path_given: true,
            error_message: 'Not detected .ruby-version file!'
          }
        })
      end

      it 'return proper version_info hash - when Detected .ruby-version file, but file is empty!' do
        expect(File).to receive(:read).with(described_class::RUBY_VERSION_FILENAME).and_return('')

        expect(call).to eq({
          supported: described_class::SUPPORTED_VERSIONS,
          default: described_class::DEFAULT_VERSION,
          detected: nil,
          other: {
            relative_path_given: true,
            error_message: 'Detected .ruby-version file, but file is empty!'
          }
        })
      end

      it 'return proper version_info hash - when Detected .ruby-version file, but file contain unknown format!' do
        expect(File).to receive(:read).with(described_class::RUBY_VERSION_FILENAME).and_return('ruby-3.0.3')

        expect(call).to eq({
          supported: described_class::SUPPORTED_VERSIONS,
          default: described_class::DEFAULT_VERSION,
          detected: nil,
          other: {
            relative_path_given: true,
            error_message: 'Detected .ruby-version file, but file contain unknown format!'
          }
        })
      end

      it 'return proper version_info hash - with detected version' do
        expect(File).to receive(:read).with(described_class::RUBY_VERSION_FILENAME).and_return('3.0.3')

        expect(call).to eq({
          supported: described_class::SUPPORTED_VERSIONS,
          default: described_class::DEFAULT_VERSION,
          detected: 3.0,
          other: {
            relative_path_given: true,
            error_message: nil
          }
        })
      end
    end

    context 'when absolute path given, so detection is disabled' do
      let(:path) { '/some/absolute/path/to/file.rb' }

      it 'return proper version_info hash - with default version' do
        expect(call).to eq({
          supported: described_class::SUPPORTED_VERSIONS,
          default: described_class::DEFAULT_VERSION,
          detected: nil,
          other: {
            relative_path_given: false,
            error_message: nil
          }
        })
      end
    end
  end
end
