# frozen_string_literal: true

# Set up user and pastes relationship
class AddUserIdToPastes < ActiveRecord::Migration[7.0]
  def change
    add_reference :pastes, :user, foreign_key: true
  end
end
