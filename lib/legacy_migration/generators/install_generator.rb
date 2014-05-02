require 'rails/generators'

module LegacyMigration
  class InstallGenerator < Rails::Generators::Base
    desc "Install LegacyMigration files"

    def create_legacy_structure
      empty_directory "legacy"
      empty_directory "legacy/models"
      empty_directory "legacy/migrators"
      empty_directory "legacy/config"
    end

    def create_database_yml_sample
      create_file "legacy/config/database.yml", <<-FILE
adapter: mysql2
database: <%= ENV['LEGACY_DB_NAME'] %>
pool: 5
username: <%= ENV['LEGACY_DB_USER'] %>
password: <%= ENV['LEGACY_DB_PASSWORD'] %>
host: <%= ENV['LEGACY_DB_HOST'] %>
port: <%= ENV["LEGACY_DB_PORT"] %>
encoding: utf8
    FILE
    end

    def create_main_migrator_file
      create_file "legacy/main_migrator.rb", <<-FILE
LegacyMigration.main do
  # You can run migrators (put them in legacy/migrators folder) here
  # eg: 
  #     BookToPublicationMigrator.migrate_each Legacy::Book
end
      FILE
    end
  end
end