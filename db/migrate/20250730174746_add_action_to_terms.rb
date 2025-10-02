class AddActionToTerms < ActiveRecord::Migration[7.1]
  def change
    add_column :terms, :action, :integer, default: 0, null: false
  end
end
