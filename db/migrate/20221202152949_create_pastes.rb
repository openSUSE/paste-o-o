# frozen_string_literal: true

# Create the paste model
class CreatePastes < ActiveRecord::Migration[7.0]
  def change
    create_table :pastes do |t|
      t.string :author, null: false
      t.string :title, null: false, default: 'Untitled Paste'
      t.boolean :private, null: false, default: true
      t.datetime :remove_at, null: false
      t.string :permalink, null: false

      t.timestamps
    end
  end
end
