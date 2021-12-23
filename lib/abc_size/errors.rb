# frozen_string_literal: true

module AbcSize
  class Error < StandardError; end

  class EmptyFileError < Error; end

  class UnknownFormatError < Error; end

  class UnsupportedVersionError < Error; end
end
