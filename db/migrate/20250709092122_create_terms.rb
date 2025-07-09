class CreateTerms < ActiveRecord::Migration[7.1]
  def change
    create_table :terms do |t|
      t.integer :subject, null: false
      t.string :content, null: false

      t.timestamps
    end
  end
end
