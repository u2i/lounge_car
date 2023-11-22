# frozen_string_literal: true

class LoungeCarCreate<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :<%= table_name %> do |t|
<%= migration_data -%>
      t.timestamps null: false
    end
  end
end