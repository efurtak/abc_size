# frozen_string_literal: true

require 'active_support/core_ext/hash/deep_merge'

# rubocop:disable Metrics/BlockLength
RSpec.describe AbcSize::VersionDetector do
  describe '#call' do
    let(:call) { described_class.new(path).call }

    let(:version_info) do
      {
        supported: described_class::SUPPORTED_VERSIONS,
        default: described_class::DEFAULT_VERSION,
        detected: nil,
        other: {
          relative_path_given: true,
          error_message: nil
        }
      }
    end

    context 'when relative path given, so detection is enabled' do
      let(:path) { 'some/relative/path/to/file.rb' }

      it 'return proper version_info hash - when Not detected .ruby-version file!' do
        allow(File).to receive(:read).and_raise(Errno::ENOENT)

        expect(call).to eq(
          version_info.deep_merge(other: { error_message: 'Not detected .ruby-version file!' })
        )
      end

      it 'return proper version_info hash - when Detected .ruby-version file, but file is empty!' do
        allow(File).to receive(:read).with(described_class::RUBY_VERSION_FILENAME).and_return('')

        expect(call).to eq(
          version_info.deep_merge(other: { error_message: 'Detected .ruby-version file, but file is empty!' })
        )
      end

      # rubocop:disable Layout/LineLength
      it 'return proper version_info hash - when Detected .ruby-version file, but file contain unknown format!' do
        allow(File).to receive(:read).with(described_class::RUBY_VERSION_FILENAME).and_return('ruby-3.0.3')

        expect(call).to eq(
          version_info.deep_merge(other: { error_message: 'Detected .ruby-version file, but file contain unknown format!' })
        )
      end
      # rubocop:enable Layout/LineLength

      it 'return proper version_info hash - with detected version' do
        allow(File).to receive(:read).with(described_class::RUBY_VERSION_FILENAME).and_return('3.0.3')

        expect(call).to eq(
          version_info.merge(detected: 3.0)
        )
      end
    end

    context 'when absolute path given, so detection is disabled' do
      let(:path) { '/some/absolute/path/to/file.rb' }

      it 'return proper version_info hash - with default version' do
        expect(call).to eq(
          version_info.deep_merge(other: { relative_path_given: false })
        )
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
