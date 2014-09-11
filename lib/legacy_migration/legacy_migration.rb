require 'database_cleaner'

module LegacyMigration
  extend self
  include ActiveSupport::Configurable

  attr_accessor :main_block

  def main(&main_block)
    self.main_block = main_block
  end

  def load_main
    require "#{Rails.root}/#{legacy_folder}/main_migrator"
  end

  def start_migration
    load_dependencies
    ActiveRecord::Base.transaction do
      destroy_current_records_if_needed
      main_block.call
    end
  end

  def database_configuration
    @database_configuration ||= load_database_configuration
  end

  private

  def load_database_configuration
    location = Rails.root.join(legacy_folder, 'config', 'database.yml')
    config_content = File.read(location)
    evaled_config = ERB.new(config_content).result
    hashed_config = YAML.load(evaled_config)

    HashWithIndifferentAccess.new(hashed_config)
  end

  def require_in_folder(folder)
    Dir["#{Rails.root}/#{folder}/**/*"].select do |filename|
      File.file?(filename)
    end.each do |model|
      require model
    end
  end

  def load_dependencies
    load_legacy_base
    load_models
    load_migrators
  end

  def load_legacy_base
    require 'legacy_migration/models/base'
  end

  def load_models
    require_in_folder "#{legacy_folder}/models"
  end

  def load_migrators
    require_in_folder "#{legacy_folder}/migrators"
  end

  def legacy_folder
    @legacy_folder ||= config.legacy_folder || 'legacy'
  end

  def destroy_current_records_if_needed
    destroy_setting = LegacyMigration.config.destroy_current_records
    if destroy_setting.present?
      destruction_strategy = destroy_setting == true ? :truncation : destroy_setting
      DatabaseCleaner.strategy = destruction_strategy
      DatabaseCleaner.clean
    end
  end
end

# you can use LM as well as LegacyMigration
LM = LegacyMigration
