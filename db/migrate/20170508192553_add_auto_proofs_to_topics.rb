class AddAutoProofsToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :auto_proofs, :string, array: true, default: '{}'
  end
end
