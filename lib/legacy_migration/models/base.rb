module LegacyMigration
  class Base < ActiveRecord::Base
    establish_connection LegacyMigration.database_configuration

    self.abstract_class = true

    # Some systems can use `type` attribute for something.
    # In Rails 3+, this method is needed for STI
    # To make this work, we are overriding the inheritance
    # column used for STI.
    def self.inheritance_column
      if inheritance_column = LegacyMigration.config.inheritance_column
        :sti_type
      else
        :type
      end
    end

    def readonly?
      true # the legacy database must keep untouched
    end

    before_destroy { |record| raise ActiveRecord::ReadOnlyRecord }
  end
end
