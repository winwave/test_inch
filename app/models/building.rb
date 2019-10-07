class Building < ApplicationRecord

  ##########################################################################
  # METHODS
  ##########################################################################
  def self.create_import(attributes)
    building = Building.find_or_initialize_by(reference: attributes['reference'])
    if building.new_record?
      building.update(attributes)
    else
      building.update(manager_name: attributes['manager_name'])
    end
    building.save
  end
end
