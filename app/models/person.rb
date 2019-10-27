class Person < ApplicationRecord

  include Versionable

  ##########################################################################
  # CONSTANTS
  ##########################################################################
  REGEXP_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/.freeze
  VERSIONING_ATTRIBUTES = %w(email home_phone_number mobile_phone_number address).freeze

  ##########################################################################
  # VALIDATORS
  ##########################################################################
  validates :email, format: { with: REGEXP_EMAIL, message: 'INVALID_FORMAT' }, allow_blank: true

  ##########################################################################
  # METHODS
  ##########################################################################
  def self.create_import(attributes)
    person = Person.find_or_initialize_by(reference: attributes['reference'])
    if person.new_record?
      person.update(attributes)
    else
      VERSIONING_ATTRIBUTES.each do |key|
        person.update_versioning_attribute(key, attributes[key])
      end
    end
    person.save
  end

end
