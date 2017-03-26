class AddArticleToRecipes < ActiveRecord::Migration
  def change
    add_reference :recipes, :article, index: true, foreign_key: true
  end
end
