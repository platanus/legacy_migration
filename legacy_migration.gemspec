# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'legacy_migration/version'

Gem::Specification.new do |s|
  s.name        = "legacy_migration"
  s.version     = LegacyMigration::VERSION
  s.authors     = ["Julio García"]
  s.email       = ["julioggonz@gmail.com"]
  s.homepage    = "http://github.com/platanus/legacy_migration"
  s.summary     = "A rails tool to migrate old (and maybe crappy) databases into new ones"
  s.description = "Migrate old databases to rails models."
  s.files       =  Dir["README.md","Gemfile","Rakefile", "lib/**/*.rb"]
  s.license     = 'MIT'

  s.add_dependency 'rails', '>= 3.2'
  s.add_dependency 'database_cleaner', '>= 1.3.0'
end
