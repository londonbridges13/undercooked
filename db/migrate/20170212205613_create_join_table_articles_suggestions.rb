class CreateJoinTableArticlesSuggestions < ActiveRecord::Migration
  def change
    create_join_table :articles, :suggestions do |t|
       t.index [:article_id, :suggestion_id]
       t.index [:suggestion_id, :article_id]
    end
  end
end
