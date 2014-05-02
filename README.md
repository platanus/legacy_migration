# LegacyMigration

## What it is?

The use case of migrate an old database into a new one is a common task, and we only wanted to abstract everything as possible to let the developer to focus into the details of the data being transformed.

## How this works?

Basically, LegacyMigration is a Rails gem that permits you to transform data from a database to another, allowing the definition of ActiveRecord models that targets your old database and a set of classes (`migrators`) that allows you to transform an old record into a new one. Because you have an ActiveRecord model to work, you can do everything you can do with ActiveRecord.

## Installation

Add this in your Gemfile:

```ruby
gem 'legacy_migration', github: 'platanus/legacy_migration'
```

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

```yml
adapter: legacy_db_adapter # mysql2, postgres, sqlite3, etc
database: legacy_db_name
username: legacy_db_user
password: legacy_db_password
host: legacy_db_host
port: legacy_db_port
```

After that, you should have to create your legacy models inside the `models` folder. For example, for a legacy table called `tbl_person`, you can create a file called `models/person.rb` and put a code like this:

```ruby
module Legacy
  class Person < LM::Base
    self.table_name = 'tbl_person'
  end
end
```

Note that we inherited the model class from `LegacyMigration::Base` (aliased as `LM::Base`) instead of `ActiveRecord::Base`. The `LegacyMigration::Base` class defines the database configuration to use and help with possible errors with the use of the `type` attribute in some systems (eg: Redmine). Aditionally, the `Person` class is namespaced under a `Legacy` module. This is only to prevent collisions with the system normal models.

Then, you should define how do you want to migrate the data from a place to another. For example, to translate a `Legacy::Person` object into a `User` object, you must create a `migrator` class, maybe something like `PersonToUserMigrator`. Create a file named `person_to_user_migrator` in the `migrators` folder and define your migrator like this:

```ruby
class PersonToUserMigrator < LM::ModelToModelMigrator
  model User, :from => :person

  def migrate_model
    {
      email: person.e_mail,
      username: person.user_name
    }
  end
end
```

The `model` method allows you to specify the model you want to create with this migrator (a `User`) and the name you want to use for the model you are migrating for. You should have to define a `migrate_model` method. This method should return a hashmap that is a mapping between the new model and the older.

Finally, the `main_migrator.rb` file contains only this:

```ruby
LegacyMigration.main do
  
end
```

Well, it's empty, but you must define what you want to migrate and in which order do the migrations, so you can put something like this:

```ruby
LegacyMigration.main do
  PersonToUserMigrator.migrate_each Legacy::Person
end
```

And that's all. To run the migration you can run:

    rake legacy:migrate

## Configuration

In the same `main_migrator.rb` file, you can put a `configure` block that allows you to set some settings.

```ruby
LegacyMigration.configure do |config|
  # This forces to empty a current table being migrated to
  # before doing some work. (To avoid collisions)
  config.destroy_current_records = true
  # This allows you to define a inheritance_column
  # when the old system is using a `type` column for
  # something. (like redmine)
  config.inheritance_column = 'sti_type'
end

LegacyMigration.main do
  # ...
end
```
