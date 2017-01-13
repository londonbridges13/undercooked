class AddDisplayTopicToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :display_topic, :string
  end
end
