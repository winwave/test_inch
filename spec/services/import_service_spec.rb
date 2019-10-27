require 'rails_helper'

describe ImportService do

  describe 'import person csv' do
    let(:csv_persons_data) do
      [
        {
          reference: '1',
          firstname: 'Henri',
          lastname: 'Dupont',
          home_phone_number: '0123456798',
          mobile_phone_number: '0623456789',
          email: 'h.dupont@gmail.com',
          address: '10 Rue La bruyère'
        },
        {
          reference: '2',
          firstname: 'Jean',
          lastname: 'Durand',
          home_phone_number: '0123336799',
          mobile_phone_number: '0663456789',
          email: 'jdurand@gmail.com',
          address: '40 Rue René Clair'
        }
      ]
    end

    let(:csv_persons) { generate_csv(csv_persons_data) }

    context 'import persons have never been created' do
      before do
        import = ImportService.new(file_path: csv_persons.path)
        import.create_person_import
      end
      it 'should be return the right number of persons added' do
        expect(Person.count).to eq(2)
      end

      it 'should return the right name for each' do
        person1 = Person.find_by(reference: 1)
        person2 = Person.find_by(reference: 2)

        expect(person1.firstname).to eq('Henri')
        expect(person1.lastname).to eq('Dupont')

        expect(person2.firstname).to eq('Jean')
        expect(person2.lastname).to eq('Durand')
      end
    end

    context 'update person atributes' do
      let(:csv_person1_data) do
        [
          {
            reference: '1',
            firstname: 'Henri',
            lastname: 'Dupont',
            home_phone_number: '0129999999',
            mobile_phone_number: '0699999999',
            email: 'h.dupont_changed@gmail.com',
            address: '10 Rue La bruyère 2'
          }
        ]
      end

      let(:csv_person1) { generate_csv(csv_person1_data) }

      before do
        import = ImportService.new(file_path: csv_persons.path)
        import.create_person_import
      end

      it 'should always return the right number of person' do
        import = ImportService.new(file_path: csv_person1.path)

        import.create_person_import

        expect(Person.count).to eq(2)
      end

      it 'should update home phone number' do
        person1 = Person.find_by(reference: 1)
        import = ImportService.new(file_path: csv_person1.path)

        import.create_person_import

        expect { person1.reload }.to change { person1.home_phone_number }
          .from('0123456798')
          .to('0129999999')
      end

      it 'should update mobile phone number' do
        person1 = Person.find_by(reference: 1)
        import = ImportService.new(file_path: csv_person1.path)

        import.create_person_import

        expect { person1.reload }.to change { person1.mobile_phone_number }
          .from('0623456789')
          .to('0699999999')
      end

      it 'should update address' do
        person1 = Person.find_by(reference: 1)
        import = ImportService.new(file_path: csv_person1.path)

        import.create_person_import

        expect { person1.reload }.to change { person1.address }
          .from('10 Rue La bruyère')
          .to('10 Rue La bruyère 2')
      end

      it 'should update email' do
        person1 = Person.find_by(reference: 1)
        import = ImportService.new(file_path: csv_person1.path)

        import.create_person_import

        expect { person1.reload }.to change { person1.email }
          .from('h.dupont@gmail.com')
          .to('h.dupont_changed@gmail.com')
      end

      it 'should not update others attributes' do
        person1 = Person.find_by(reference: 1)
        import = ImportService.new(file_path: csv_person1.path)

        import.create_person_import

        expect { person1.reload }.to not_change { person1.firstname }
          .and not_change { person1.lastname }
      end

      context 'update old version attributes' do
        before do
          person = Person.find_by_reference(1)
          person.versionings.create(type_attribute: 'home_phone_number', value: '0129999999')
          person.versionings.create(type_attribute: 'mobile_phone_number', value: '0699999999')
          person.versionings.create(type_attribute: 'email', value: 'h.dupont_changed@gmail.com')
          person.versionings.create(type_attribute: 'address', value: '10 Rue La bruyère 2')
        end

        it 'should not update email' do
          person1 = Person.find_by(reference: 1)
          import = ImportService.new(file_path: csv_person1.path)

          import.create_person_import

          expect { person1.reload }.to_not change { person1.email }
        end

        it 'should not update address' do
          person1 = Person.find_by(reference: 1)
          import = ImportService.new(file_path: csv_person1.path)

          import.create_person_import

          expect { person1.reload }.to_not change { person1.address }
        end

        it 'should not update mobile_phone_number' do
          person1 = Person.find_by(reference: 1)
          import = ImportService.new(file_path: csv_person1.path)

          import.create_person_import

          expect { person1.reload }.to_not change { person1.mobile_phone_number }
        end

        it 'should not update home_phone_number' do
          person1 = Person.find_by(reference: 1)
          import = ImportService.new(file_path: csv_person1.path)

          import.create_person_import

          expect { person1.reload }.to_not change { person1.home_phone_number }
        end

      end
    end

  end

  describe 'import building' do
    let(:csv_buildings_data) do
      [
        {
          reference: '1',
          address: '10 Rue La bruyère',
          zip_code: '75009',
          city: 'Paris',
          country: 'France',
          manager_name: 'Martin Faure'
        },
        {
          reference: '2',
          address: '40 Rue René Clair',
          zip_code: '75018',
          city: 'Paris',
          country: 'France',
          manager_name: 'Martin Faure'
        }
      ]
    end

    let(:csv_buildings) { generate_csv(csv_buildings_data) }

    context 'import buildings have never been created' do
      before do
        import = ImportService.new(file_path: csv_buildings.path)
        import.create_building_import
      end

      it 'should be return the right number of buildings added' do
        expect(Building.count).to eq(2)
      end

      it 'should return the right attributes for each' do
        building1 = Building.find_by(reference: 1)
        building2 = Building.find_by(reference: 2)

        expect(building1.zip_code).to eq('75009')
        expect(building1.manager_name).to eq('Martin Faure')

        expect(building2.zip_code).to eq('75018')
        expect(building2.manager_name).to eq('Martin Faure')
      end
    end

    context 'update building' do
      let(:csv_buildings_update_data) do
        [
          {
            reference: '1',
            address: '10 Rue La bruyère',
            zip_code: '750019',
            city: 'Paris',
            country: 'France',
            manager_name: 'Martin Faure Updated'
          },
          {
            reference: '2',
            address: '40 Rue René Clair',
            zip_code: '75020',
            city: 'Paris',
            country: 'France',
            manager_name: 'Martin Faure Updated'
          }
        ]
      end

      let(:csv_buildings_update) { generate_csv(csv_buildings_update_data) }

      before do
        import = ImportService.new(file_path: csv_buildings.path)
        import.create_building_import
      end

      it 'should always return the right number of buildings' do
        import = ImportService.new(file_path: csv_buildings_update.path)
        import.create_building_import

        expect(Building.count).to eq(2)
      end

      it 'should update manager name' do
        building1 = Building.find_by_reference('1')
        import = ImportService.new(file_path: csv_buildings_update.path)

        import.create_building_import

        expect { building1.reload }.to change { building1.manager_name }
          .from('Martin Faure')
          .to('Martin Faure Updated')
      end

      it 'should not update others attributes' do
        building1 = Building.find_by_reference('1')
        import = ImportService.new(file_path: csv_buildings_update.path)

        import.create_building_import

        expect { building1.reload }.to not_change { building1.address }
          .and not_change { building1.zip_code }
          .and not_change { building1.city }
          .and not_change { building1.country }
      end
      context 'with old version attributes' do
        before do
          building = Building.find_by_reference(1)
          building.versionings.create(type_attribute: 'manager_name', value: 'Martin Faure Updated')
        end
        it 'should not update manager name' do
          building1 = Building.find_by_reference('1')
          import = ImportService.new(file_path: csv_buildings_update.path)

          import.create_building_import

          expect { building1.reload }.to_not change { building1.manager_name }
        end
      end
    end
  end
end