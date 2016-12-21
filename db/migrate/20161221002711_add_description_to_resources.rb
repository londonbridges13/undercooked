class AddDescriptionToResources < ActiveRecord::Migration
  def change
    add_column :resources, :desc, :text
  end
end
