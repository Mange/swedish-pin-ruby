# frozen_string_literal: true

module Personnummer
  class Personnummer
    attr_reader :year, :month, :day, :sequence_number, :control_digit

    def initialize(year:, month:, day:, sequence_number:, control_digit:)
      @year = year
      @month = month
      @coordination_number = day > 60
      @day = (day > 60 ? day - 60 : day)
      @sequence_number = sequence_number
      @control_digit = control_digit
    end

    def birthday
      Date.civil(year, month, day)
    end

    # Checks if the Personnummer is a coordination number (Samordningsnummer)
    # (TrueClass/FalseClass)
    def coordination_number?
      @coordination_number
    end

    # Returns the short/long formatted number
    def to_s(length = 10, now = Time.now)
      if length != 10 && length != 12
        raise ArgumentError, "The only supported lengths are 10 or 12."
      end

      [
        format_date(length == 12),
        separator(length, now),
        "%03d" % sequence_number,
        control_digit
      ].join("")
    end

    # Returns the age of the Personnummer's owner
    # (Integer)
    def age(now = Time.now)
      age = now.year - year - (birthday_passed_this_year?(now) ? 0 : 1)
      [0, age].max
    end

    # Checks if the Personnummer's owner is male
    # (TrueClass/FalseClass)
    def male?
      sequence_number.odd?
    end

    # Checks if the Personnummer's owner is female
    # (TrueClass/FalseClass)
    def female?
      sequence_number.even?
    end

    private

    def separator(length, now)
      if length == 10 && year <= (now.year - 100)
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
