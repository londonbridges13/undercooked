require 'bcrypt'
module Entity
  module V1
    class UsersEntity < Grape::Entity
      expose :id, :name, :email, :image, :password
    end
  end
end
