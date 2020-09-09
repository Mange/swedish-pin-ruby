# personnummer [![Build Status](https://secure.travis-ci.org/Mange/personnummer-ruby.png?branch=master)](http://travis-ci.org/Mange/personnummer-ruby)

Validate, parse, and generate [Swedish Personal Identity Numbers](https://en.wikipedia.org/wiki/Personal_identity_number_(Sweden)) ("PINs", or *Personnummer*).

## Installation

Add this to your `Gemfile`

```ruby
gem 'personnummer', git: 'https://github.com/Mange/personnummer-ruby.git'
```

Then run `bundle install`.

## Usage

```ruby
require 'personnummer'

Personnummer.valid?("8507099805") # => true
pin = Personnummer.parse("8507099805") # => #<Personnummer::PIN …>
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
fake1 = Personnummer.generate
fake2 = Personnummer.generate(user.birthday)
```

## License

MIT.

Started out as a fork of https://github.com/personnummer/ruby
