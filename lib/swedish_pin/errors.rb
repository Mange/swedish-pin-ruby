# frozen_string_literal: true

module SwedishPIN
  # Error that represents a problem that occurred while parsing a
  # _Personnummer_.
  #
  # You can inspect both the {input} attribute and check the subclass to build
  # more helpful error messages for your users.
  class ParseError < RuntimeError
    # The input string that caused the error.
    #
    # @example
    #   error.input # => "112233@4455"
    attr_reader :input

    # Create a new instance of this error.
    #
    # @param [String] message The error message.
    # @param [String] input The input string that could not be parsed.
    def initialize(message, input)
      super(message)
      @input = input
    end
  end

  # The format of the input string does not look like a _Personnummer_. This
  # could happen because the string has the wrong length, or because extra
  # characters are placed inside of it.
  class InvalidFormat < ParseError
  end

  # The date embedded in the input string is not a valid date.
  class InvalidDate < ParseError
  end

  # The control digit at the end does not match the rest of the input. This
  # could mean that the input has a typo.
  class InvalidChecksum < ParseError
  end
end
