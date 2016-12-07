class AddResourceToArticles < ActiveRecord::Migration
  def change
    add_reference :articles, :resource, index: true, foreign_key: true
  end
end
