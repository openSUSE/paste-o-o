# frozen_string_literal: true

# Create auth handling model for the application
class CreateAuths < ActiveRecord::Migration[7.0]
  def change
    create_table :auths do |t|
      t.string :uid
      t.string :key, null: false
      t.string :name, null: false
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :auths, :key, unique: true
  end
end
