# frozen_string_literal: true

module SwedishPIN
  # @api private
  #
  # Parser for _Personnummer_.
  #
  # Please use {SwedishPIN.parse} or {SwedishPIN.valid?} instead.
  class Parser
    MATCHER = /
      \A
      (?<century>\d{2})?
      (?<year>\d{2})
      (?<month>\d{2})
      (?<day>\d{2})
      (?<separator>[+\- ]?)
      (?<sequence_number>\d{3})
      (?<control_digit>\d)
      \z
    /x.freeze
    private_constant :MATCHER

    # Setup a new parser.
    def initialize(input, now = Time.now)
      unless input.is_a?(String)
        raise ArgumentError, "Expected String, got #{input.inspect}"
      end

      @input = input
      @now = now
      @matches = MATCHER.match(input.strip)
    end

    # Raise {ParseError} if anything in the input isn't valid.
    def validate
      validate_match
      validate_luhn
      validate_date
    end

    # Check validity without raising.
    def valid?
      validate
      true
    rescue
      false
    end

    # Return +Hash+ of parsed values to be used with {SwedishPIN::Personnummer#initialize}.
    def parse
      validate

      {
        year: full_year,
        month: month,
        day: day,
        sequence_number: sequence_number,
        control_digit: control_digit
      }
    end

    private

    attr_reader :now

    def full_year
      century * 100 + year
    end

    def century
      if @matches["century"]
        Integer(@matches["century"], 10)
      else
        guess_century
      end
    end

    def year
      Integer(@matches["year"], 10)
    end

    def month
      @month ||= Integer(@matches["month"], 10)
    end

    def day
      @day ||= Integer(@matches["day"], 10)
    end

    # Day, but adjusted for coordination numbers being possible.
    def real_day
      if day > 60
        day - 60
      else
        day
      end
    end

    def sequence_number
      Integer(@matches["sequence_number"], 10)
    end

    def control_digit
      Integer(@matches["control_digit"], 10)
    end

    def guess_century
      century = now.year / 100

      # Century could take up to three different values, depending on
      # combination of "future" dates and `+` separators.
      #
      #   For example, on year 2010:
      #     100101-nnnn => 2010-01-01
      #     110101-nnnn => 1911-01-01 (because 2011 has not happened yet)
      #     110101+nnnn => 1811-01-01 (1911 - 100 years)
      #     090101+nnnn => 1909-01-01 (2009 - 100 years)
      #
      # One step comes from using the `+` separator, which means "remove
      # another 100 years", despite what the rest of the date seems to imply.

      # Assume previous century on future years
      if (century * 100) + year > now.year
        century -= 1
      end

      if @matches["separator"] == "+"
        century -= 1
      end

      century
    end

    def validate_match
      unless @matches
        raise InvalidFormat.new("Input did not match expected format", @input)
      end
    end

    def validate_luhn
      comparator = [
        @matches["year"],
        @matches["month"],
        @matches["day"],
        @matches["sequence_number"]
      ].join("")

      if SwedishPIN.luhn(comparator) != control_digit
        raise InvalidChecksum.new("Control digit did not match expected value", @input)
      end
    end

    def validate_date
      raise InvalidDate.new("#{month} is not a valid month", @input) unless (1..12).cover?(month)
      raise InvalidDate.new("#{day} is not a valid day", @input) unless (1..31).cover?(real_day)

      unless Date.valid_date?(full_year, month, real_day)
        raise InvalidDate.new("Input had invalid date", @input)
      end
    end
  end
end
