class AddTopicOrderToUser < ActiveRecord::Migration
  def change
    add_column :users, :topic_order, :integer, array: true, default: '{}'
  end
end
