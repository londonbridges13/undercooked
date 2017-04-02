class AddUnitToRecipeIngredients < ActiveRecord::Migration
  def change
    add_column :recipe_ingredients, :unit, :string
  end
end
