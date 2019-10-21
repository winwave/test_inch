class PersonEmail < ApplicationRecord
  ##########################################################################
  # ASSOCIATIONS
  ##########################################################################
  belongs_to :person, dependent: :destroy
end
