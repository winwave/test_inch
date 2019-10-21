class Person < ApplicationRecord

  REGEXP_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/.freeze
  ##########################################################################
  # VALIDATORS
  ##########################################################################
  validates :email, format: { with: REGEXP_EMAIL, message: 'INVALID_FORMAT' }, allow_blank: true

  ##########################################################################
  # ASSOCIATIONS
  ##########################################################################
  has_many :person_email

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
      person_emails = person.person_email.pluck(:email)
      email = attributes['email']
      if email.present? && !person_emails.include?(email)
        person.update(email: email)
        person.person_email.create(email: email)
      end
    end
    person.save
  end

end
