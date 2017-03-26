class CreateRecipeIngredients < ActiveRecord::Migration
  def change
    create_table :recipe_ingredients do |t|
      t.float :amount

      t.timestamps null: false
    end
  end
end
