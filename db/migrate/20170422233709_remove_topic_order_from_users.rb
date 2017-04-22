class RemoveTopicOrderFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :topic_order
  end
end
