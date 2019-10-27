class CreateVersionings < ActiveRecord::Migration[6.0]
  def change
    create_table :versionings do |t|
      t.string :type
      t.string :value

      t.timestamps
    end
  end
end
