# swedish-pin

[![Inline docs](http://inch-ci.org/github/Mange/swedish-pin-ruby.svg?branch=master)](http://inch-ci.org/github/Mange/swedish-pin-ruby)

Validate, parse, and generate [Swedish Personal Identity
Numbers](https://en.wikipedia.org/wiki/Personal_identity_number_(Sweden))
("PINs", or *Personnummer*).

[API documentation](https://www.rubydoc.info/gems/swedish-pin)

## Installation

Add this to your `Gemfile`

```ruby
gem 'swedish-pin'
```

Then run `bundle install`.

## Usage

```ruby
require "swedish_pin"

# Validate strings
SwedishPIN.valid?("8507099805") # => true
SwedishPIN.valid?("8507099804") # => false

# Parse numbers to get more information about them, or to normalize display of
# them.
pin = SwedishPIN.parse("8507099805") # => #<SwedishPIN::Personnummer …>
pin.year # => 1985
pin.birthdate # => #<Date: 1985-07-09>

# The 10-digit variant also knows about century separators.
pin.to_s     # => "850709-9805"
pin.to_s(10) # => "850709-9805"
pin.format_short(Date.civil(2025, 12, 1)) # => "850709-9805"
pin.format_short(Date.civil(2085, 12, 1)) # => "850709+9805"

# Use unofficial 12-digit format for a stable string that doesn't change
# depending on today's date when storing it.
pin.to_s(12)    # => "19850709-9805"
pin.format_long # => "19850709-9805"

# You can also generate numbers to use as example data
fake1 = SwedishPIN.generate
fake2 = SwedishPIN.generate(user.birthday)
```

## License

MIT. See `LICENSE` file for more details.

This project started out as a fork of
[personnummer/ruby](https://github.com/personnummer/ruby), but has since been
almost completely rewritten.
Despite this, the original authors retains most of the copyright since this is
derivative work.
