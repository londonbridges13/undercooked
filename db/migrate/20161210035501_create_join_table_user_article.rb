class CreateJoinTableUserArticle < ActiveRecord::Migration
  def change
    create_join_table :users, :articles do |t|
      t.index [:user_id, :article_id]
      t.index [:article_id, :user_id]
    end
  end
end
