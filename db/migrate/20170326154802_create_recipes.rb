class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :description
      t.string :author
      t.string :serving_size
      t.float :prep_time
      t.float :cooktime
      t.float :total_time

      t.timestamps null: false
    end
  end
end
