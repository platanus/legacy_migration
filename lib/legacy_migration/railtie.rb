module LegacyMigration
  class Railtie < Rails::Railtie
    initializer "Include your code after the controller is loaded" do
      # This is to ensure Rails.root exists
      ActiveSupport.on_load(:action_controller) do
        require 'legacy_migration'
        require 'legacy_migration/legacy_migration'
        require 'legacy_migration/migrators/migrator'
        require 'legacy_migration/migrators/model_to_model_migrator'
      end
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end

    generators do
      require 'legacy_migration/generators/install_generator'
    end
  end
end