# Inch test

Hello, This is the app I have done for the test. I build the app with PostgreSQL in database instead of sqlite. And Rspec for the test.

* There are 3 files principal in my algorithm
*services/import_service.rb*  
*models/building.rb* 
*model/person/rb*  

* For the test Rspec  
*spec/services/import_service_spec.rb*  
*spec/support/csv_helper.rb*

## Requirements
* ruby 2.6.3p62
* psql (PostgreSQL) 11.0

## Dependencies

```bash
bundle install
```

## Database creation

```bash
bundle exec rake db:create
bundle exec rake db:migrate
```

## Run

### Import person

```bash
rake import:import_persons FILE_PATH
 ```
### Import building

```bash
rake import:import_buildings FILE_PATH
 ```
For exemple: 

```bash
rake import:import_buildings storage/person_test.csv
 ```
## Run test
```bash
rspec
 ```
