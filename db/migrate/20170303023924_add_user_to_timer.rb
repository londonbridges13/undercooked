class AddUserToTimer < ActiveRecord::Migration
  def change
    add_reference :timers, :user, index: true, foreign_key: true
  end
end
