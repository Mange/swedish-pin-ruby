# frozen_string_literal: true

require "date"

module Personnummer
  class Generator
    attr_reader :date

    def initialize(date)
      @date = date || random_date
    end

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
