require 'rails_helper'

describe 'Persons API', type: :request do
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
  let(:expected_keys) { %w(id reference email home_phone_number mobile_phone_number firstname lastname address created_at updated_at) }

  describe 'GET #index' do
    before do
      import = ImportService.new(file_path: csv_persons.path)
      import.create_person_import
    end
    it 'responds with the right number of person' do
      get '/api/v1/persons', {}

      expect(response.status).to eq 200
      expect(body_as_json.size).to eq 2
    end
  end

  describe 'GET #show' do
    before do
      import = ImportService.new(file_path: csv_persons.path)
      import.create_person_import
    end
    it 'responds with the expected keys' do
      get "/api/v1/persons/#{Person.last.id}", {}

      expect(response.status).to eq 200
      expect(body_as_json.keys).to match_array(expected_keys)
    end
  end

  describe 'POST #create' do
    let(:params) {
      {
        person: {
          reference: '2',
          firstname: 'Jean',
          lastname: 'Durand',
          home_phone_number: '0123336799',
          mobile_phone_number: '0663456789',
          email: 'jdurand@gmail.com',
          address: '40 Rue René Clair'
        }
      }
    }
    it 'responds with the expected values' do
      post "/api/v1/persons", params: params

      expect(response.status).to eq 201
      expect(body_as_json).to include(
        'reference' => '2',
        'firstname' => 'Jean',
        'lastname' => 'Durand',
        'home_phone_number' => '0123336799',
        'mobile_phone_number' => '0663456789',
        'email' => 'jdurand@gmail.com',
        'address' => '40 Rue René Clair'
      )
    end

    it 'should save email in versioning table' do
      post "/api/v1/persons", params: params

      person_versoining_email = Person.last.versionings.attribute_values('email')

      expect(person_versoining_email).to include('jdurand@gmail.com')
    end

    it 'should save address in versioning table' do
      post "/api/v1/persons", params: params

      person_versoining_address = Person.last.versionings.attribute_values('address')

      expect(person_versoining_address).to include('40 Rue René Clair')
    end

    it 'should save home_phone_number in versioning table' do
      post "/api/v1/persons", params: params

      person_versoining_home_phone_number = Person.last.versionings.attribute_values('home_phone_number')

      expect(person_versoining_home_phone_number).to include('0123336799')
    end

    it 'should save mobile_phone_number in versioning table' do
      post "/api/v1/persons", params: params

      person_versoining_mobile_phone_number = Person.last.versionings.attribute_values('mobile_phone_number')
      expect(person_versoining_mobile_phone_number).to include('0663456789')
    end
  end

  describe 'PUT #update' do
    before do
      import = ImportService.new(file_path: csv_persons.path)
      import.create_person_import
    end

    it 'should email was changed' do
      person = Person.find_by_reference('2')
      put "/api/v1/persons/#{person.id}", params: {
        person: {
          email: 'jdurand_update@gmail.com'
        }
      }
      expect(response.status).to eq 200
      expect { person.reload }.to change { person[:email] }
        .from('jdurand@gmail.com')
        .to('jdurand_update@gmail.com')
    end

    it 'should address was changed' do
      person = Person.find_by_reference('2')
      put "/api/v1/persons/#{person.id}", params: {
        person: {
          address: '40 Rue René Clair updated'
        }
      }
      expect(response.status).to eq 200
      expect { person.reload }.to change { person[:address] }
        .from('40 Rue René Clair')
        .to('40 Rue René Clair updated')
    end

    it 'should home_phone_number was changed' do
      person = Person.find_by_reference('2')
      put "/api/v1/persons/#{person.id}", params: {
        person: {
          home_phone_number: '0199999999'
        }
      }
      expect(response.status).to eq 200
      expect { person.reload }.to change { person[:home_phone_number] }
        .from('0123336799')
        .to('0199999999')
    end

    it 'should mobile_phone_number was changed' do
      person = Person.find_by_reference('2')
      put "/api/v1/persons/#{person.id}", params: {
        person: {
          mobile_phone_number: '0699999999'
        }
      }
      expect(response.status).to eq 200
      expect { person.reload }.to change { person[:mobile_phone_number] }
        .from('0663456789')
        .to('0699999999')
    end

    context 'with old version attributes' do
      let(:csv_person1_data_new) do
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

      let(:csv_person1) { generate_csv(csv_person1_data_new) }
      before do
        import = ImportService.new(file_path: csv_person1.path)
        import.create_person_import
      end

      it 'should email is changed' do
        person = Person.find_by_reference('1')
        put "/api/v1/persons/#{person.id}", params: {
          person: {
            email: 'h.dupont@gmail.com'
          }
        }
        expect(response.status).to eq 200
        expect { person.reload }.to change { person[:email] }
          .from('h.dupont_changed@gmail.com')
          .to('h.dupont@gmail.com')
      end

      it 'should address is changed' do
        person = Person.find_by_reference('1')
        put "/api/v1/persons/#{person.id}", params: {
          person: {
            address: '10 Rue La bruyère'
          }
        }
        expect(response.status).to eq 200
        expect { person.reload }.to change { person[:address] }
          .from('10 Rue La bruyère 2')
          .to('10 Rue La bruyère')
      end

      it 'should home_phone_number is changed' do
        person = Person.find_by_reference('1')
        put "/api/v1/persons/#{person.id}", params: {
          person: {
            home_phone_number: '0123336799'
          }
        }
        expect(response.status).to eq 200
        expect { person.reload }.to change { person[:home_phone_number] }
          .from('0129999999')
          .to('0123336799')
      end

      it 'should mobile_phone_number is changed' do
        person = Person.find_by_reference('1')
        put "/api/v1/persons/#{person.id}", params: {
          person: {
            mobile_phone_number: '0663456789'
          }
        }
        expect(response.status).to eq 200
        expect { person.reload }.to change { person[:mobile_phone_number] }
          .from('0699999999')
          .to('0663456789')
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      import = ImportService.new(file_path: csv_persons.path)
      import.create_person_import
    end

    it 'should return to status 204 with no content' do
      person = Person.find_by_reference('2')
      delete "/api/v1/persons/#{person.id}"

      expect(response.status).to eq 204
    end
  end
end