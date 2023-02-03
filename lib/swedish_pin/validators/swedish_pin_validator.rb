# frozen_string_literal: true

# Validator class for swedish_pin validations
#
# ==== Examples
#
# Validates that attribute is a valid swedish_pin number.
# If empty value passed for attribute it fails.
#
#   class Person < ActiveRecord::Base
#     attr_accessible :number
#     validates :personal_number, swedish_pin: true
#   end
class SwedishPinValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    record.errors.add(attribute, message, **options) unless SwedishPIN.valid?(value)
  end

  private

  def message
    options[:message] || :invalid
  end
end
