class AddVersionableToVersioning < ActiveRecord::Migration[6.0]
  def change
    add_reference :versionings, :versionable, polymorphic: true, index: true
  end
end
