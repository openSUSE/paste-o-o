# frozen_string_literal: true

# Add user role handling
class AddRoleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role, :string
  end
end
