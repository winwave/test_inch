class Person < ApplicationRecord

  REGEXP_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/.freeze
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
      person.update(
        home_phone_number: attributes['home_phone_number'],
        mobile_phone_number: attributes['mobile_phone_number'],
        address: attributes['address']
      )
      if person[:email].blank? && attributes['email'].present?
        person.update(email: attributes['email'])
      end
    end
    person.save
  end

end
