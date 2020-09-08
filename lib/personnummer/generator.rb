# frozen_string_literal: true

require "date"

module Personnummer
  # @private
  # @api private
  #
  # Generator for PINs.
  class Generator
    # The date all generated PINs will be based on.
    attr_reader :date

    # Creates a new generator for a particular date.
    def initialize(date)
      @date = date || random_date
    end

    # Generate a {Personnummer::Personnummer} with the given sequence number.
    def generate(sequence_number)
      sequence_number ||= random_sequence_number
      Personnummer.new(
        year: date.year,
        month: date.month,
        day: date.day,
        sequence_number: sequence_number,
        control_digit: control_digit(sequence_number)
      )
    end

    private

    def random_date
      Date.today - Random.rand(0..(110 * 365))
    end

    def random_sequence_number
      Random.rand(0..999)
    end

    def control_digit(sequence_number)
      padded = ("%03d" % sequence_number)
      ::Personnummer.luhn("#{date.strftime("%y%m%d")}#{padded}")
    end
  end
end
