require "minitest/autorun"
require "test_helper"
require "swedish_pin"

class PersonnummerTest < Minitest::Test
  parallelize_me!

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
    assert_equal 2009, SwedishPIN.parse("090909-9640", now).year
    assert_equal 1989, SwedishPIN.parse("890909-7761", now).year

    # These PINs can't be from 1910, or else they would've been using `+`
    # separator. It must be 2010. First date is in the future, but it's still
    # on the 100th year since 1910.
    assert_equal 2010, SwedishPIN.parse("101011-5283", now).year
    assert_equal 2010, SwedishPIN.parse("101010-3289", now).year

    # This PIN, on the other hand, probably can't be from 2011 since that year
    # has not happened yet. That means that 1911 is more likely. It's not been
    # 100 years yet, so the `-` separator should be used.
    assert_equal 1911, SwedishPIN.parse("111111-4425", now).year
    # …and this one uses `+` anyway, so it must be even further back, in 1811.
    assert_equal 1811, SwedishPIN.parse("111111+4425", now).year

    # These would've been in 2010 with `-`, but uses `+`.
    assert_equal 1910, SwedishPIN.parse("100101+7969", now).year
    assert_equal 1909, SwedishPIN.parse("090909+9640", now).year
  end

  def test_large_century_guessing_sample
    1000.times do
      original = SwedishPIN.generate
      pin_string = original.to_s(12)

      from_10 = SwedishPIN.parse(original.to_s(10))

      assert_equal pin_string, from_10.to_s(12), -> {
        "PIN #{pin_string} parsed as #{from_10.to_s(10)} → #{from_10.to_s(12)}"
      }
    end
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

  def test_10_digit_at_100_years
    # NOTE: Should become + the same year as the person's 100th birthday, even
    # before their birthday.
    #
    # From Skatteverket:
    #   > Mellan födelsetiden och födelsenumret finns ett bindestreck (-), som
    #   > byts ut mot ett plustecken (+) det år en person fyller 100 år.
    # See: https://skatteverket.se/privat/folkbokforing/personnummerochsamordningsnummer.4.3810a01c150939e893f18c29.html
    full_pin = "19231202-3100"
    [
      #      Current time    Expected 10-digit PIN
      [Time.new(2022, 12, 31), "231202-3100"],
      [Time.new(2023, 1, 1), "231202+3100"]
    ].each do |(now, short_pin)|
      # Serializing the long pin into the short format works correctly
      pin = SwedishPIN.parse(full_pin, now)
      assert_equal(
        short_pin,
        pin.to_s(10, now),
        -> {
          "On #{now.to_date} the PIN #{full_pin} should " \
            "be #{short_pin} when using 10 digits"
        }
      )

      # …and parsing the short pin should yield the correct long PIN.
      pin = SwedishPIN.parse(short_pin, now)
      assert_equal(
        full_pin,
        pin.to_s(12, now),
        -> {
          "On #{now.to_date} the short PIN #{short_pin} should " \
          "be parsed into #{full_pin}"
        }
      )
    end
  end

  def test_equal_to_same_pin
    pin1 = SwedishPIN.parse("900707-9925")
    pin2 = SwedishPIN.parse("19900707-9925")
    pin3 = SwedishPIN.parse("198507699810")

    assert_equal pin1, pin2
    assert_equal pin2, pin1

    assert pin1 != pin3
    assert pin3 != pin2
  end

  def test_sorting_date
    # rubocop:disable Layout/ExtraSpacing
    oldest = SwedishPIN.parse("18990707-1279") # 1899-07-07
    old = SwedishPIN.parse("991201+7705")      # 1899-12-01
    new = SwedishPIN.parse("990101-5181")      # 1999-01-01
    # rubocop:enable Layout/ExtraSpacing

    assert_equal [oldest, old, new], [old, oldest, new].sort
  end

  def test_sorting_sequence_numbers
    pin1 = SwedishPIN.parse("200101-1937")
    pin2 = SwedishPIN.parse("200101-4709")
    pin3 = SwedishPIN.parse("200101-8395")

    assert_equal [pin1, pin2, pin3], [pin2, pin1, pin3].sort
  end

  def test_sorting_with_nil_crashes_with_expected_error
    pin = SwedishPIN.generate
    assert_raises(ArgumentError, /comparison of/) do
      [pin, nil].sort
    end
  end

  def test_hashes_on_underlying_pin
    pin1 = SwedishPIN.generate
    pin2 = SwedishPIN.generate

    hash = {pin1 => 1}

    assert_equal 1, hash[pin1]
    assert_nil hash[pin2]

    pin1_copy = SwedishPIN.parse(pin1.format_long)
    assert_equal 1, hash[pin1_copy]

    assert_nil hash[pin1.format_long]
    assert_nil hash[pin1.format_short]
  end
end
