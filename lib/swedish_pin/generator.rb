# frozen_string_literal: true

require "date"

module SwedishPIN
  # @private
  # @api private
  #
  # Generator for PINs.
  class Generator
    # Creates a new generator for a particular date.
    def initialize(random: Random)
      @random = random
    end

    # Generate a {Personnummer} with the given sequence number.
    def generate(date: random_date, sequence_number: random_sequence_number)
      # Handle someone explicitly passing `nil`.
      date ||= random_date
      sequence_number ||= random_sequence_number

      Personnummer.new(
        year: date.year,
        month: date.month,
        day: date.day,
        sequence_number: sequence_number,
        control_digit: control_digit(date, sequence_number)
      )
    end

    private

    def random_date
      Date.today - @random.rand(0..(110 * 365))
    end

    def random_sequence_number
      @random.rand(0..999)
    end

    def control_digit(date, sequence_number)
      padded = ("%03d" % sequence_number)
      SwedishPIN.luhn("#{date.strftime("%y%m%d")}#{padded}")
    end
  end
end
