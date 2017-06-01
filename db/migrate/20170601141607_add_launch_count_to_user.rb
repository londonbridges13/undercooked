class AddLaunchCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :launch_count, :integer
  end
end
