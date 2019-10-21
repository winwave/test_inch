require 'rails_helper'

describe 'Buildings API', type: :request do
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
  let(:expected_keys) { %w(id reference address zip_code city country manager_name created_at updated_at) }

  describe 'GET #index' do
    before do
      import = ImportService.new(file_path: csv_buildings.path)
      import.create_building_import
    end
    it 'responds with the right number of building' do
      get '/api/v1/buildings', {}

      expect(response.status).to eq 200
      expect(body_as_json.size).to eq 2
    end
  end

  describe 'GET #show' do
    before do
      import = ImportService.new(file_path: csv_buildings.path)
      import.create_building_import
    end
    it 'responds with the expected keys' do
      get "/api/v1/buildings/#{Building.last.id}"

      expect(response.status).to eq 200
      expect(body_as_json.keys).to match_array(expected_keys)
    end
  end

  describe 'POST #create' do
    it 'responds with the expected keys' do
      post "/api/v1/buildings", params: {
        building: {
          reference: '1',
          address: '10 Rue La bruyère',
          zip_code: '750019',
          city: 'Paris',
          country: 'France',
          manager_name: 'Martin Faure'
        }
      }
      expect(response.status).to eq 201
      expect(body_as_json).to include(
        'reference' => '1',
        'address' => '10 Rue La bruyère',
        'zip_code' => '750019',
        'city' => 'Paris',
        'country' => 'France',
        'manager_name' => 'Martin Faure'
      )
    end
  end

  describe 'PUT #update' do
    before do
      import = ImportService.new(file_path: csv_buildings.path)
      import.create_building_import
    end
    it 'should email was changed' do
      building = Building.find_by_reference('2')
      put "/api/v1/buildings/#{building.id}", params: {
        building: {
          'manager_name': 'Martin Faure Updated'
        }
      }

      expect(response.status).to eq 200
      expect { building.reload }.to change { building.manager_name }
        .from('Martin Faure')
        .to('Martin Faure Updated')
    end
  end

  describe 'DELETE #destroy' do
    before do
      import = ImportService.new(file_path: csv_buildings.path)
      import.create_building_import
    end

    it 'should return to status 204 with no content' do
      building = Building.find_by_reference('2')
      delete "/api/v1/buildings/#{building.id}"

      expect(response.status).to eq 204
    end
  end
end