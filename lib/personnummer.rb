require "date"

module Personnummer
  autoload :Generator, "personnummer/generator"
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

  def self.generate(date = nil, sequence_number = nil)
    Generator.new(date).generate(sequence_number)
  end

  # Implementation of Luhn algorithm
  def self.luhn(str)
    sum = 0

    (0...str.length).each do |i|
      v = str[i].to_i
      v *= 2 - (i % 2)
      if v > 9
        v -= 9
      end
      sum += v
    end

    ((sum.to_f / 10).ceil * 10 - sum.to_f).to_i
  end
end
