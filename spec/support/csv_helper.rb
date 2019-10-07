module CsvHelpers
  def generate_csv(csv_data)
    csv_string = CSV.generate do |csv|
      csv << csv_data.first.keys
      csv_data.inject(csv) { |acc, row| acc << row.values }
    end

    file = Tempfile.new
    file.write(csv_string)
    file.rewind
    file
  end
end

RSpec.configure do |c|
  c.include CsvHelpers
end