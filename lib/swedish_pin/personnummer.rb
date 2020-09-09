# frozen_string_literal: true

module SwedishPIN
  # Represents a parsed and valid _Personnummer_ or _Samordningsnummer_ for a
  # particular individual.
  #
  # Determine if this is a _Personnummer_ or a _Samordningsnummer_ using {coordination_number?}.
  #
  # @see https://en.wikipedia.org/wiki/Personal_identity_number_(Sweden) Personnummer on Wikipedia.
  class Personnummer
    attr_reader :year, :month, :day, :sequence_number, :control_digit
    # @!attribute [r] year
    #   The full year of the _personnummer_. For example +1989+.
    #   @return [Integer]
    # @!attribute [r] month
    #   The month digit of the _personnummer_. 1 for January up until 12 for December.
    #   @return [Integer]
    # @!attribute [r] day
    #   The day of the month of the _personnummer_. This will be for the real
    #   day, even for coordination numbers.
    #   @see #coordination_number?
    #   @return [Integer]
    # @!attribute [r] sequence_number
    #   The number after the separator.
    #   A common reason to access this is to check the sex of the person. You
    #   might want to look at {#male?} and {#female?} instead.
    #   @note This attribute returns an +Integer+, but this sequence needs to
    #     be zero-padded up to three characters if you intend to display it (i.e.
    #     +3+ is +"003"+).
    #   @return [Integer]
    # @!attribute [r] control_digit
    #   The last digit of the _personnummer_. It acts as a checksum of the
    #   previous numbers.
    #   @return [Integer]

    # @api private
    # @private
    #
    # Initializes a new instance from specific values. Please consider using
    # {SwedishPIN.generate} instead of you want custom instances.
    def initialize(year:, month:, day:, sequence_number:, control_digit:)
      @year = year
      @month = month
      @coordination_number = day > 60
      @day = (day > 60 ? day - 60 : day)
      @sequence_number = sequence_number
      @control_digit = control_digit
    end

    # Return the birthday for the person that is represented by this
    # _Personnummer_.
    #
    # @return [Date] the date of birth
    def birthday
      Date.civil(year, month, day)
    end

    # Returns +true+ if this number is a _Samordningsnummer_ (coordination
    # number). This is a number that is granted to non-Swedish citizens until
    # the time that they become citizens.
    #
    # Coordination numbers are identical to a PIN, except that the "day"
    # component has +60+ added to it (i.e. <code>28+60=88</code>).
    #
    # @note The {day} attribute will still return a valid date day, even for coordination numbers.
    # @see https://sv.wikipedia.org/wiki/Samordningsnummer Samordningsnummer on Wikipedia (Swedish)
    def coordination_number?
      @coordination_number
    end

    # Formats the PIN in the official "10-digit" format. This is the "real"
    # _Personnummer_ string.
    #
    # *Format:* +yymmdd-nnnn+ or <code>yymmdd+nnnn</code>
    #
    # The _Personnummer_ specification says that starting from the year of a
    # person's 100th birthday, the separator in their _personnummer_ will
    # change from a <code>-</code> into a <code>+</code>.
    #
    # That means that every time you display a _personnummer_ you also must
    # consider the time of this action. Something that was read on date A and
    # outputted on date B might not use the same string representation.
    #
    # For this reason, the real _personnummer_ is usually not what you want to
    # store, only what you want to display in some cases.
    #
    # This library recommends that you use {format_long} for storage.
    #
    # @param [Time, Date] now The time when this personnummer is supposed to be displayed.
    # @return [String] the formatted number
    # @see #format_long
    def format_short(now = Time.now)
      [
        format_date(false),
        short_separator(now),
        "%03d" % sequence_number,
        control_digit
      ].join("")
    end

    # Formats the _personnummer_ in the unofficial "12-digit" format that
    # includes the century and doesn't change separator depending on when the
    # number is supposed to be shown.
    #
    # This format is being adopted in a lot of places in favor of the
    # "10-digit" format ({format_short}), but as of 2020 it remains an
    # unofficial format.
    #
    # *Format:* +yyyymmdd-nnnn+
    #
    # @see #format_short
    def format_long
      [
        format_date(true),
        "-",
        "%03d" % sequence_number,
        control_digit
      ].join("")
    end

    # Formats the PIN into a +String+.
    #
    # You can provide the desired length to get different formats.
    #
    # @note The length isn't how long the resulting string will be as the
    #   resulting string will also have a separator included. The formats are
    #   colloquially called "10-digit" and "12-digit", which is why they are
    #   referred to as "length" here.
    #
    # +10+ or +nil+:: {format_short}
    # +12+:: {format_long}
    #
    # @param [Integer, nil] length The desired format.
    # @param [Time, Date] now The current time. Only used by {format_short}.
    # @raise [ArgumentError] If not provided a valid length.
    # @return [String]
    # @see #format_short
    # @see #format_long
    def to_s(length = 10, now = Time.now)
      case length
      when 10 then format_short(now)
      when 12 then format_long
      else raise ArgumentError, "The only supported lengths are 10 or 12."
      end
    end

    # Returns the age of the person this _personnummer_ represents, as an
    # integer of years since birth.
    #
    # Swedish age could be defined as such: A person will be +0+ years old when
    # born, and +1+ 12 months after that, on the same day or the day after in
    # the case of leap years. This is the same way most western countries count
    # age.
    #
    # If the {birthday} is in the future, then +0+ will be returned.
    #
    # @param [Time, Date] now The current time.
    # @return [Integer] Number of 12 month periods that have passed since the birthdate; +0+ or more.
    def age(now = Time.now)
      age = now.year - year - (birthday_passed_this_year?(now) ? 0 : 1)
      [0, age].max
    end

    # Returns +true+ if the _personnummer_ represents a person that is legally
    # identified as +male+.
    # @return [true, false]
    def male?
      sequence_number.odd?
    end

    # Returns +true+ if the _personnummer_ represents a person that is legally
    # identified as +female+.
    # @return [true, false]
    def female?
      sequence_number.even?
    end

    private

    def short_separator(now)
      if year <= (now.year - 100)
        "+"
      else
        "-"
      end
    end

    def format_date(include_century)
      [
        (include_century ? pad(year / 100) : nil),
        pad(year % 100),
        pad(month),
        pad(coordination_number? ? day + 60 : day)
      ].join("")
    end

    def pad(num)
      "%02d" % num
    end

    def birthday_passed_this_year?(now)
      now.month > month || (now.month == month && now.day >= day)
    end
  end
end
