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
    it 'responds with the expected keys' do
      post "/api/v1/persons", params: {
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

    it 'should save email in table person_email' do
      post "/api/v1/persons", params: {
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
      person_email = Person.last.person_email
      expect(person_email.pluck(:email)).to include('jdurand@gmail.com')
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

    context 'update old version email of person' do
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
        import = ImportService.new(file_path: csv_person1.path)
        import.create_person_import
      end

      it 'should email was changed to the old email' do
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