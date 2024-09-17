class AddMarkedByAndMarkedKindToPaste < ActiveRecord::Migration[7.1]
  def change
    add_reference :pastes, :marked_by, foreign_key: { to_table: :users }
    add_column :pastes, :marked_kind, :integer, null: false, default: 0
  end
end
