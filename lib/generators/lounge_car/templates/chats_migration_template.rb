# frozen_string_literal: true

class LoungeCarCreateChats < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :chats do |t|
      t.integer 'input', default: 0, null: false
      t.integer 'output', default: 0, null: false
      t.timestamps null: false
    end
  end
end