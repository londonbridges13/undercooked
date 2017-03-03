class CreateTimers < ActiveRecord::Migration
  def change
    create_table :timers do |t|
      t.integer :seconds

      t.timestamps null: false
    end
  end
end
