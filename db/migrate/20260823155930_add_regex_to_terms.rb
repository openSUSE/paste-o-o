class AddRegexToTerms < ActiveRecord::Migration[8.1]
  def change
    add_column :terms, :regex, :boolean, default: false, null: false
  end
end
