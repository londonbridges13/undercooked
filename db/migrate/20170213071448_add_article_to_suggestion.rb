class AddArticleToSuggestion < ActiveRecord::Migration
  def change
    add_reference :suggestions, :article, index: true, foreign_key: true
  end
end
