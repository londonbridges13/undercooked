class CreateJoinTableTopicArticle < ActiveRecord::Migration
  def change
    create_join_table :topics, :articles do |t|
      t.index [:topic_id, :article_id]
      t.index [:article_id, :topic_id]
    end
  end
end
