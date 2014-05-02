module LegacyMigration
  class ModelToModelMigrator < Migrator
    include ActiveSupport::Callbacks

    define_callbacks :migrate

    attr_reader :old_instance, :new_instance

    def initialize
      load_new_instance!
    end

    def migrate(old_record)
      load_old_instance!(old_record)
      new_instance.assign_attributes migrate_model
      new_instance.id = old_instance.id if old_instance.id.present?
      save
      new_instance
    end

    private

    def save
      new_instance.valid? ? persist : log_errors
    end

    def persist
      run_callbacks :migrate do
        print "."
        new_instance.save
      end
    end

    def log_errors
      log "Model of class #{old_instance.class} with id #{old_instance.id} could not be migrated to an instance of #{new_instance.class}. Errors: #{new_instance.errors.as_json}"
    end

    def log(message)
      puts message
      Rails.logger.warn(message)
    end

    def load_new_instance!
      @new_instance = build_new_instance
      define_singleton_method(new_model_name) do
        @new_instance
      end
    end

    def build_new_instance
      self.class.current_model.new
    end

    def new_model_name
      self.class.current_model.model_name.singular
    end

    def load_old_instance!(old_instance)
      @old_instance = old_instance
      define_singleton_method(self.class.old_model_name) do
        @old_instance
      end
    end

    class << self
      attr_accessor :current_model, :old_model_name

      def model(model_class, options = {})
        self.current_model = model_class
        self.old_model_name = options.fetch(:from, :old_model)
      end

      def after_migrate(*filters, &blk)
        set_callback :migrate, :after, *filters, &blk
      end

      def migrate_each(legacy_model, destroy_current_records: nil)
        current_model.destroy_all if destroy_current_records?(destroy_current_records)

        legacy_model.find_each do |legacy_model_instance|
          self.new.migrate(legacy_model_instance)
        end
      end

      private

      def destroy_current_records?(destroy_current_records)
        if destroy_current_records.present?
          destroy_current_records
        else
          !!LegacyMigration.config.destroy_current_records
        end
      end
    end
  end
end
