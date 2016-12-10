class CreateJoinTableTagArticle < ActiveRecord::Migration
  def change
    create_join_table :tags, :articles do |t|
      t.index [:tag_id, :article_id]
      t.index [:article_id, :tag_id]
    end
  end
end
