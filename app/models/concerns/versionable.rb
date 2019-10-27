module Versionable
  extend ActiveSupport::Concern

  included do
    has_many :versionings, :as => :versionable
  end

  def update_versioning_attribute(type, value)

    if versionings.where(type_attribute: type, value: value).empty?
      hash = {}
      hash[type] = value
      update(hash)
      versionings.create(type_attribute: type, value: value)
    end
  end
end