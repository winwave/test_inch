class Versioning < ApplicationRecord

  ##########################################################################
  # ASSOCIATIONS
  ##########################################################################
  belongs_to :versionable, :polymorphic => true

  ##########################################################################
  # SCOPES
  ##########################################################################
  scope :attribute_values, ->(attribute) {
    where(type_attribute: attribute).pluck(:value)
  }

end
