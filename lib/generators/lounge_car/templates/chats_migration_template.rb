# frozen_string_literal: true

class LoungeCarCreateChats < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :chats do |t|
      t.timestamps null: false
    end
  end
end