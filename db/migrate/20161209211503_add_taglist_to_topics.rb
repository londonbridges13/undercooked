class AddTaglistToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :taglist, :string, array: true, default: []
  end
end
