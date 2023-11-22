# frozen_string_literal: true

module LoungeCar
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('templates', __dir__)

    def create_migrations_and_models
      migration_template('chats_migration_template.rb', 'db/migrate/lounge_car_create_chats.rb', migration_version: migration_version)
      migration_template('messages_migration_template.rb', 'db/migrate/lounge_car_create_messages.rb', migration_version: migration_version)
      template 'chat_model_template.rb', 'app/models/chat.rb'
      template 'message_model_template.rb', 'app/models/message.rb'
    end

    #     def copy_migration
    #       if model_exists?
    #         migration_template 'migration_existing.rb', "db/migrate/add_lounge_car_to_#{table_name}.rb", migration_version: migration_version
    #       else
    #         migration_template 'migration_new.rb', "db/migrate/lounge_car_create_#{table_name}.rb", migration_version: migration_version
    #       end
    #     end
    #
    #     def generate_model
    #       invoke 'active_record:model', [name], migration: false unless model_exists?
    #     end
    #
    #     def migration_data
    #       <<RUBY
    #       t.integer 'role', default: 0, null: false
    #       t.string 'content'
    #       t.json 'data'
    #       t.string 'type'
    # RUBY
    #     end
    #
    #     def model_exists?
    #       File.exist?(File.join(destination_root, model_path))
    #     end
    #
    #     def model_path
    #       @model_path ||= File.join('app', 'models', "#{file_path}.rb")
    #     end
    #
    def migration_version
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end

    def self.next_migration_number(_)
      sleep 1
      Time.now.utc.strftime('%Y%m%d%H%M%S')
    end
  end
end
