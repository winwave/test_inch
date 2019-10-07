require 'csv'

class ImportService

  def initialize(params = {})
    @file_path = params.fetch(:file_path)
  end

  def create_person_import
    CSV.foreach(@file_path, headers: true) do |row|
      Person.create_import(row.to_hash)
    end
  end

  def create_building_import
    CSV.foreach(@file_path, headers: true) do |row|
      Building.create_import(row.to_hash)
    end
  end
end