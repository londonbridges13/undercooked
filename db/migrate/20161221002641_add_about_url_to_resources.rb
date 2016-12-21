class AddAboutUrlToResources < ActiveRecord::Migration
  def change
    add_column :resources, :about_url, :text
  end
end
