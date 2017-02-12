class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.boolean :rejected
      t.string :reason
      t.string :evidence

      t.timestamps null: false
    end
  end
end
