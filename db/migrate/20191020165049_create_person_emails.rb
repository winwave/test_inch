class CreatePersonEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :person_emails do |t|
      t.integer :person_id
      t.string :email

      t.timestamps
    end
  end
end
