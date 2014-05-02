# LegacyMigration

## What it is?

The use case of migrate an old database into a new one is a common task, and we only wanted to abstract everything as possible to let the developer to focus into the details of the data being transformed.

## How this works?

Basically, LegacyMigration is a Rails gem that permits you to transform data from a database to another, allowing the definition of ActiveRecord models that targets your old database and a set of classes (`migrators`) that allows you to transform an old record into a new one. Because you have an ActiveRecord model to work, you can do everything you can do with ActiveRecord.

## Getting Started

# Installation

Add this in your Gemfile:

    gem 'legacy_migration'

Now you need a place to put your legacy models, the trasformation logic and the old database configuration. To have all of these, run:

    rails generate legacy_migration:install

This creates a folder at your project level called **legacy**. Inside legacy you have something like this:

    - legacy
        - config
            database.yml
        - migrators
        - models
        main_migrator.rb

The first thing you should need to do is to tell to LegacyMigration where is your old database. Inside your `config/database.yml`, you should put the configuration of your old database. Something like this:

    adapter: mysql2
    database: <%= ENV['LEGACY_DB_NAME'] %>
    username: <%= ENV['LEGACY_DB_USER'] %>
    password: <%= ENV['LEGACY_DB_PASSWORD'] %>
    host: <%= ENV['LEGACY_DB_HOST'] %>
    port: <%= ENV["LEGACY_DB_PORT"] %>

After that, you should have to create your legacy models inside the `models` folder. For example, for a legacy table called `tbl_person`, you can create a file called `models/person.rb` and put a code like this:

    module Legacy
      class Person < LM::Base
        self.table_name = 'tbl_person'
      end
    end

Note that we inherited the model from `LegacyMigration::Base` (aliased as `LM::Base`) instead of `ActiveRecord::Base`. This helps 





