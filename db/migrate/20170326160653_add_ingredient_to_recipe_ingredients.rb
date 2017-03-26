class AddIngredientToRecipeIngredients < ActiveRecord::Migration
  def change
    add_reference :recipe_ingredients, :ingredient, index: true, foreign_key: true
  end
end
