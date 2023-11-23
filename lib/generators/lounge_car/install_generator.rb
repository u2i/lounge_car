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

    def migration_version
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end

    def self.next_migration_number(_)
      sleep 1
      Time.now.utc.strftime('%Y%m%d%H%M%S')
    end
  end
end
