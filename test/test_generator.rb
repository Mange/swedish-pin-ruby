require "minitest/autorun"
require "test_helper"
require "swedish_pin"

class GeneratorTest < Minitest::Test
  def test_generating_specific_date_and_sequence
    assert_equal(
      "19890707-8136",
      SwedishPIN.generate(Date.civil(1989, 7, 7), "813").to_s(12)
    )
    assert_equal(
      "19890707-8136",
      SwedishPIN.generate(Date.civil(1989, 7, 7), 813).to_s(12)
    )

    assert_equal(
      "890707-0133",
      SwedishPIN.generate(Date.civil(1989, 7, 7), 13).to_s(10)
    )
  end

  def test_generating_specific_date_picks_random_sequence
    date = Date.civil(1989, 7, 7)

    pin1 = SwedishPIN::Generator.new(random: Random.new(1337)).generate(date: date)
    pin2 = SwedishPIN::Generator.new(random: Random.new(4242)).generate(date: date)
    pin3 = SwedishPIN::Generator.new(random: Random.new(1337)).generate(date: date)

    assert_equal pin1.to_s, pin3.to_s
    refute_equal pin1.to_s, pin2.to_s

    assert_equal date, pin1.birthday
    assert_equal date, pin2.birthday
    assert_equal date, pin3.birthday
  end

  def test_generating_picks_random_date_and_sequence
    pin1 = SwedishPIN::Generator.new(random: Random.new(1337)).generate
    pin2 = SwedishPIN::Generator.new(random: Random.new(4242)).generate
    pin3 = SwedishPIN::Generator.new(random: Random.new(1337)).generate

    assert_equal pin1.to_s, pin3.to_s
    refute_equal pin1.to_s, pin2.to_s
  end

  def test_only_generates_valid_pins
    1000.times do
      # If any pin is invalid, then it should fail to parse or parse
      # differently.
      pin = SwedishPIN.generate
      begin
        copy = SwedishPIN.parse(pin.to_s(12))
        assert_equal pin.to_s(12), copy.to_s(12)
      rescue SwedishPIN::ParseError => error
        flunk "Generated invalid PIN: #{pin.to_s(12)} (#{pin.inspect}) - #{error}"
      end
    end
  end
end
