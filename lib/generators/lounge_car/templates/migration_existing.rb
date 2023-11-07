# frozen_string_literal: true

class AddLoungeCarTo<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
  def self.up
    change_table :<%= table_name %> do |t|
<%= migration_data -%>
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end