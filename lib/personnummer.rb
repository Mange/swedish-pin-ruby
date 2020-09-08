require "date"

module Personnummer
  autoload :ParseError, "personnummer/parse_error"
  autoload :Parser, "personnummer/parser"
  autoload :Personnummer, "personnummer/personnummer"

  # Return Personnummer object from given string/integer with options
  # (Personnummer)
  def self.parse(string, now = Time.now)
    result = Parser.new(string, now).parse
    Personnummer.new(
      year: result.fetch(:year),
      month: result.fetch(:month),
      day: result.fetch(:day),
      sequence_number: result.fetch(:sequence_number),
      control_digit: result.fetch(:control_digit)
    )
  end

  # Check validity of string/integer input as Personnummer
  # (TrueClass/FalseClass)
  def self.valid?(string, now = Time.now)
    Parser.new(string, now).valid?
  rescue ArgumentError
    false
  end
end
