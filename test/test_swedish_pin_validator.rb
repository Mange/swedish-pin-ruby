require "test_helper"

require "minitest/autorun"
require "swedish_pin"

Value = Class.new(String) do
  def blank?
    empty?
  end
end


class SwedishPinValidatorTest < Minitest::Test
  parallelize_me!

  def test_validation_error
    validator = ::SwedishPinValidator.new({message: :message})
    record = Record.new(Errors.new([]))
    validator.validate_each(record, :personal_number, "19850!!!7099805")

    assert_equal [[:personal_number, :message, message: :message]], record.errors.list
  end

  def test_validation_no_error_allow_blank
    validator = ::SwedishPinValidator.new({allow_blank: true})
    record = Record.new(Errors.new([]))
    validator.validate_each(record, :personal_number, Value.new(""))

    assert_equal [], record.errors.list
  end

  def test_validation_valid
    validator = ::SwedishPinValidator.new({})
    record = Record.new(Errors.new([]))
    validator.validate_each(record, :personal_number, "198507099805")

    assert_equal [], record.errors.list
  end
end
