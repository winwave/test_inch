require 'csv'

namespace :import do
  task import_persons: :environment do
    import = ImportService.new(file_path: ARGV.last)
    import.create_person_import
  end

  task import_buildings: :environment do
    import = ImportService.new(file_path: ARGV.last)
    import.create_building_import
  end
end