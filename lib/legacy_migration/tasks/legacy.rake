namespace :legacy do
  desc "Migrate from a legacy database to this database using the data in the legacy folder"
  task :migrate => :environment do
    LegacyMigration.load_main
    LegacyMigration.start_migration
  end
end
