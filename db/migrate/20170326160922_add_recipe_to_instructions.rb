class AddRecipeToInstructions < ActiveRecord::Migration
  def change
    add_reference :instructions, :recipe, index: true, foreign_key: true
  end
end
