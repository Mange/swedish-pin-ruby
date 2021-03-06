require "minitest/autorun"
require "swedish_pin"

class PersonnummerTest < Minitest::Test
  def assert_parse_error(input, type)
    assert_raises(type) { SwedishPIN.parse(input) }
  end

  def test_valid_12_digit_personnummer
    personnummer = SwedishPIN.parse("198507099805")
    assert_equal false, personnummer.coordination_number?
    assert_equal 1985, personnummer.year
    assert_equal 7, personnummer.month
    assert_equal 9, personnummer.day
    assert_equal Date.civil(1985, 7, 9), personnummer.birthday
    assert_equal 980, personnummer.sequence_number
    assert_equal 5, personnummer.control_digit

    assert_equal "850709-9805", personnummer.to_s
    assert_equal "850709-9805", personnummer.to_s(10)
    assert_equal "19850709-9805", personnummer.to_s(12)
  end

  def test_valid_12_digit_coordination_number
    personnummer = SwedishPIN.parse("198507699802")
    assert_equal true, personnummer.coordination_number?
    assert_equal 1985, personnummer.year
    assert_equal 7, personnummer.month
    assert_equal 9, personnummer.day
    assert_equal Date.civil(1985, 7, 9), personnummer.birthday
    assert_equal 980, personnummer.sequence_number
    assert_equal 2, personnummer.control_digit

    assert_equal "850769-9802", personnummer.to_s
    assert_equal "850769-9802", personnummer.to_s(10)
    assert_equal "19850769-9802", personnummer.to_s(12)
  end

  def test_valid_10_digit_personnummer
    personnummer = SwedishPIN.parse("8507099805")
    assert_equal false, personnummer.coordination_number?
    assert_equal 1985, personnummer.year
    assert_equal 7, personnummer.month
    assert_equal 9, personnummer.day
    assert_equal Date.civil(1985, 7, 9), personnummer.birthday
    assert_equal 980, personnummer.sequence_number
    assert_equal 5, personnummer.control_digit

    assert_equal "850709-9805", personnummer.to_s
    assert_equal "850709-9805", personnummer.to_s(10)
    assert_equal "19850709-9805", personnummer.to_s(12)
  end

  def test_valid_10_digit_coordination_number
    personnummer = SwedishPIN.parse("8507699802")
    assert_equal true, personnummer.coordination_number?
    assert_equal 1985, personnummer.year
    assert_equal 7, personnummer.month
    assert_equal 9, personnummer.day
    assert_equal Date.civil(1985, 7, 9), personnummer.birthday
    assert_equal 980, personnummer.sequence_number
    assert_equal 2, personnummer.control_digit

    assert_equal "850769-9802", personnummer.to_s
    assert_equal "850769-9802", personnummer.to_s(10)
    assert_equal "19850769-9802", personnummer.to_s(12)
  end

  def test_valid_10_digit_with_century_indicator
    personnummer = SwedishPIN.parse("850709+9805")
    assert_equal false, personnummer.coordination_number?
    assert_equal 1885, personnummer.year
    assert_equal 7, personnummer.month
    assert_equal 9, personnummer.day
    assert_equal Date.civil(1885, 7, 9), personnummer.birthday
    assert_equal 980, personnummer.sequence_number
    assert_equal 5, personnummer.control_digit

    assert_equal "850709+9805", personnummer.to_s
    assert_equal "850709+9805", personnummer.to_s(10)
    assert_equal "18850709-9805", personnummer.to_s(12)
  end

  def test_century_guessing
    now = Time.new(2010, 10, 10)

    # If the date has not passed yet in this century, guess last century.
    assert_equal 1912, SwedishPIN.parse("121212-2442", now).year
    assert_equal 1910, SwedishPIN.parse("101011-5283", now).year
    assert_equal 2009, SwedishPIN.parse("090909-9640", now).year
    assert_equal 1989, SwedishPIN.parse("890909-7761", now).year

    # Today counts as "passed".
    assert_equal 2010, SwedishPIN.parse("101010-3289", now).year

    # The "+" separator means >= 100 years, so don't guess the wrong century
    assert_equal 1911, SwedishPIN.parse("111111-4425", now).year
    assert_equal 1811, SwedishPIN.parse("111111+4425", now).year

    assert_equal 1910, SwedishPIN.parse("100101+7969", now).year
    assert_equal 1909, SwedishPIN.parse("090909+9640", now).year
  end

  def test_validation_of_control_digits
    assert SwedishPIN.valid?("198507099805")
    assert !SwedishPIN.valid?("198507099804")
    assert !SwedishPIN.valid?("198507099806")
    assert_parse_error("198507099806", SwedishPIN::InvalidChecksum)

    assert SwedishPIN.valid?("198507099813")
    assert !SwedishPIN.valid?("198507099812")
    assert !SwedishPIN.valid?("198507099814")
    assert_parse_error("198507099814", SwedishPIN::InvalidChecksum)

    # Separator does not matter
    assert SwedishPIN.valid?("850709-9813")
    assert SwedishPIN.valid?("850709+9813")
    assert !SwedishPIN.valid?("850709-9812")
    assert !SwedishPIN.valid?("850709-9814")
    assert_parse_error("850709-9814", SwedishPIN::InvalidChecksum)

    # Century does not matter when checking control digit
    assert SwedishPIN.valid?("19850709-9813")
    assert SwedishPIN.valid?("18850709-9813")
    assert SwedishPIN.valid?("17850709-9813")
    assert SwedishPIN.valid?("850709+9813")

    # Missing the control digit is not valid
    assert !SwedishPIN.valid?("850709-981")
    assert !SwedishPIN.valid?("850709981")
    assert !SwedishPIN.valid?("10850709981")
    assert_parse_error("108507099818", SwedishPIN::InvalidChecksum)
  end

  def test_invalid_personnummer_or_wrong_types
    [
      nil,
      [],
      {},
      false,
      true,
      0,
      188507099813
    ].each do |bad_value|
      assert !SwedishPIN.valid?(bad_value)
      assert_raises ArgumentError do
        SwedishPIN.parse(bad_value)
      end
    end

    assert_parse_error("17850709=9813", SwedishPIN::InvalidFormat)
    assert_parse_error("112233-4455", SwedishPIN::InvalidChecksum)
    assert_parse_error("19112233-4455", SwedishPIN::InvalidChecksum)
    assert_parse_error("20112233-4455", SwedishPIN::InvalidChecksum)
    assert_parse_error("9999999999", SwedishPIN::InvalidDate)
    assert_parse_error("199999999999", SwedishPIN::InvalidDate)
    assert_parse_error("199909193776", SwedishPIN::InvalidChecksum)
    assert_parse_error("Just a string", SwedishPIN::InvalidFormat)
  end

  def test_age
    pin = SwedishPIN.parse("900707-9925")

    # On their birth day and the day after
    assert_equal 0, pin.age(Time.utc(1990, 7, 7))
    assert_equal 0, pin.age(Time.utc(1990, 7, 8))

    # 6 months old
    assert_equal 0, pin.age(Time.utc(1991, 1, 7))

    # Around their 1st birthday
    assert_equal 0, pin.age(Time.utc(1991, 7, 6))
    assert_equal 1, pin.age(Time.utc(1991, 7, 7))
    assert_equal 1, pin.age(Time.utc(1991, 7, 8))

    # Much later or much earlier
    assert_equal 120, pin.age(Time.utc(2110, 12, 31))
    assert_equal 0, pin.age(Time.utc(1910, 12, 31))
  end

  def test_male?
    assert SwedishPIN.parse("19121212+1212").male?
    assert SwedishPIN.parse("198507099813").male?
    assert SwedishPIN.parse("198507699810").male?

    assert !SwedishPIN.parse("196411139808").male?
    assert !SwedishPIN.parse("198507099805").male?
    assert !SwedishPIN.parse("198507699802").male?
  end

  def test_female?
    assert SwedishPIN.parse("196411139808").female?
    assert SwedishPIN.parse("198507099805").female?
    assert SwedishPIN.parse("198507699802").female?

    assert !SwedishPIN.parse("19121212+1212").female?
    assert !SwedishPIN.parse("198507099813").female?
    assert !SwedishPIN.parse("198507699810").female?
  end

  def test_to_s_length
    pin = SwedishPIN.parse("900707-9925")

    assert_raises(ArgumentError) { pin.to_s(9) }
    assert_raises(ArgumentError) { pin.to_s(11) }
    assert_raises(ArgumentError) { pin.to_s(13) }
    assert_raises(ArgumentError) { pin.to_s(0) }
    assert_raises(ArgumentError) { pin.to_s(nil) }
  end

  def test_to_s_different_times
    pin = SwedishPIN.parse("900707-9925")

    assert_equal "900707-9925", pin.to_s(10)
    assert_equal "900707-9925", pin.to_s(10, Time.now)
    assert_equal "900707+9925", pin.to_s(10, Time.new(2090, 7, 7))
    assert_equal "19900707-9925", pin.to_s(12, Time.new(2090, 7, 7))
  end
end
