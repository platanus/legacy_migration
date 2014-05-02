$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "legacy_migration/version"

task :build do
  system "gem build legacy_migration.gemspec"
end

task :release => :build do
  system "gem push legacy_migration-#{LegacyMigration::VERSION}.gem"
end