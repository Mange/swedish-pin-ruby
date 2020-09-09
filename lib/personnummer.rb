require "date"

# Validate, parse, and generate Swedish Personal Identity Numbers.
#
# In Swedish these are called _Personnummer_. There is also a variant called
# "coordination number" (_Samordningsnummer_). Both of these are supported
# using the same API; see {Personnummer::PIN#coordination_number?}.
#
# To get started, look at {Personnummer.valid?} and {Personnummer.parse}.
module Personnummer
  autoload :Generator, "personnummer/generator"
  autoload :Parser, "personnummer/parser"
  autoload :PIN, "personnummer/pin"

  autoload :ParseError, "personnummer/errors"
  autoload :InvalidFormat, "personnummer/errors"
  autoload :InvalidDate, "personnummer/errors"
  autoload :InvalidChecksum, "personnummer/errors"

  # Parses a string of a personnummer and returns a
  # {Personnummer::PIN} or raises an error.
  #
  # Some numbers will have to relate to the current time in order to be parsed
  # correctly. For example, the PIN +201231-…+ could be in many different
  # years, including 1820, 1920, 2020, and so on.
  # This library will guess that the year is in the most recent guess that are
  # in the past. So during the year 2020 it would guess 2020, and in 2019 it
  # will guess 1920.
  #
  # @param [String] string The number to parse.
  # @param [Time] now Provide a different "parse time" context.
  # @return [Personnummer::PIN] The parsed PIN
  # @raise {Personnummer::ParseError} When the provided string was not valid.
  # @raise {ArgumentError} When the provided value was not a +String+.
  def self.parse(string, now = Time.now)
    result = Parser.new(string, now).parse
    PIN.new(
      year: result.fetch(:year),
      month: result.fetch(:month),
      day: result.fetch(:day),
      sequence_number: result.fetch(:sequence_number),
      control_digit: result.fetch(:control_digit)
    )
  end

  # Checks if a provided string is a valid _Personnummer_.
  #
  # @param [String] string The number to parse.
  # @param [Time] now Provide a different "parse time" context. See {.parse}.
  # @return [true, false] if the string was valid
  def self.valid?(string, now = Time.now)
    Parser.new(string, now).valid?
  rescue ArgumentError
    false
  end

  # Generates a valid _Personnummer_ given certain inputs. Inputs not provided
  # will be randomized.
  #
  # This is mainly useful in order to generate test data or "Lorem Ipsum"-like
  # values for use in demonstrations. Note that valid PINs might actually
  # correspond to a real person, so don't use these generated PINs for anything
  # that has a real effect.
  #
  # @example FactoryBot sequence
  #   FactoryBot.define do
  #     sequence(:swedish_pin) do |n|
  #       # Will generate every PIN for a full day, then flip over to the next
  #       # day and start the sequence over.
  #       sequence_number = n % 1000
  #       date = Date.civil(1950, 1, 1) + (n / 1000)
  #       Personnummer.generate(date, sequence_number)
  #     end
  #   end
  #
  # @example Test data
  #   user = User.new(name: "Jane Doe", pin: Personnummer.generate)
  #
  # @raise [ArgumentError] if given numbers are outside of the valid range.
  # @param [Date, Time, nil] birthday The birthday of the person the PIN identifies, or +nil+ for a random date in the past.
  # @param [String, Integer, nil] sequence_number The sequence number that correspond to the three digits after the birthday, or +nil+ to pick a random one.
  def self.generate(birthday = nil, sequence_number = nil)
    Generator.new(birthday).generate(sequence_number)
  end

  # @api private
  #
  # Implementation of Luhn algorithm.
  #
  # @param [String] digits String of digits to calculate a control digit for.
  # @return [Integer] Control digit.
  def self.luhn(digits)
    sum = 0

    (0...digits.length).each do |i|
      v = digits[i].to_i
      v *= 2 - (i % 2)
      if v > 9
        v -= 9
      end
      sum += v
    end

    ((sum.to_f / 10).ceil * 10 - sum.to_f).to_i
  end
end
