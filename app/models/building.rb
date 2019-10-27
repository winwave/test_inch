class Building < ApplicationRecord

  include Versionable
  
  ##########################################################################
  # CONSTANTS
  ##########################################################################
  VERSIONING_ATTRIBUTES = %w(manager_name).freeze

  ##########################################################################
  # METHODS
  ##########################################################################
  def self.create_import(attributes)
    building = Building.find_or_initialize_by(reference: attributes['reference'])
    if building.new_record?
      building.update(attributes)
    else
      VERSIONING_ATTRIBUTES.each do |key|
        building.update_versioning_attribute(key, attributes[key])
      end
    end
    building.save
  end
end
