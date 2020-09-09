require "minitest/autorun"
require "swedish_pin"

class GeneratorTest < Minitest::Test
  def with_predetermined_seed(seed)
    restoring_seed = Random.new_seed
    Random.srand(seed)
    yield
  ensure
    Random.srand(restoring_seed)
  end

  def test_generating_specific_date_and_sequence
    assert_equal "19890707-8136", SwedishPIN.generate(Date.civil(1989, 7, 7), "813").to_s(12)
    assert_equal "19890707-8136", SwedishPIN.generate(Date.civil(1989, 7, 7), 813).to_s(12)

    assert_equal "890707-0133", SwedishPIN.generate(Date.civil(1989, 7, 7), 13).to_s(10)
  end

  def test_generating_specific_date_picks_random_sequence
    pin1, pin2, pin3 = nil
    date = Date.civil(1989, 7, 7)

    with_predetermined_seed(1337) do
      pin1 = SwedishPIN.generate(date)
    end

    with_predetermined_seed(4242) do
      pin2 = SwedishPIN.generate(date)
    end

    with_predetermined_seed(1337) do
      pin3 = SwedishPIN.generate(date)
    end

    assert_equal pin1.to_s, pin3.to_s
    refute_equal pin1.to_s, pin2.to_s

    assert_equal date, pin1.birthday
    assert_equal date, pin2.birthday
    assert_equal date, pin3.birthday
  end

  def test_generating_picks_random_date_and_sequence
    pin1, pin2, pin3 = nil

    with_predetermined_seed(1337) do
      pin1 = SwedishPIN.generate
    end

    with_predetermined_seed(4242) do
      pin2 = SwedishPIN.generate
    end

    with_predetermined_seed(1337) do
      pin3 = SwedishPIN.generate
    end

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
