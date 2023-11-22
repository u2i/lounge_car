# frozen_string_literal: true

class LoungeCarCreateMessages < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :messages do |t|
      t.integer 'role', default: 0, null: false
      t.string 'content'
      t.json 'data'
      t.references :chat, null: false, foreign_key: true
      t.timestamps null: false
    end
  end
end