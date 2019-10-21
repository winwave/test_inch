namespace :update_table do
  task ini_table_person_email: :environment do
    Person.all.each do |person|
      PersonEmail.create(person: person, email: person.email)
    end
  end
end