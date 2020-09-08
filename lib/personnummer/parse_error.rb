# frozen_string_literal: true

module Personnummer
  class ParseError < RuntimeError
    attr_reader :input, :kind

    def initialize(message, kind, input)
      super(message)
      @kind = kind
      @input = input
    end

    def invalid_format?
      kind == :invalid_format
    end

    def checksum?
      kind == :checksum
    end

    def invalid_date?
      kind == :invalid_date
    end
  end
end
