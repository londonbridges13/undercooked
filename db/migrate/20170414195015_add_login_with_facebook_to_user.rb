class AddLoginWithFacebookToUser < ActiveRecord::Migration
  def change
    add_column :users, :login_with_facebook, :boolean
    add_column :users, :facebook_id, :string
  end
end
