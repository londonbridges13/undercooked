require 'doorkeeper/grape/helpers'
require 'bcrypt'

module API
  module V1
    class Users < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      resource :users do
        namespace 'signin' do
          desc 'Sing In (Basic)'
          post do
            email = params[:uemail]
            password = params[:upassword]
            token = params[:utoken]
            if token == nil
              # use email address to sign in
              @user = User.find_by_email(email)
              if @user.valid_password? password
                # give user a new personal access_token, and set doorkeeper_token.resource_owner_id = @user.id
                @user.access_token = Devise.friendly_token.first(35)
                @user.save
                doorkeeper_token.resource_owner_id = @user.id
                present @user.access_token
                # client should use this token to user. But server knows the user through the doorkeeper_token
                # When accessing ... hmmmmmmm
              else
                # invalid password
                present "ERROR: Invalid Credentials #{email}"
              end
            else
              # use email address to sign in
              @user = User.find_by_access_token(token)
              if @user.valid_password? password
                # give user a new personal access_token, and set doorkeeper_token.resource_owner_id = @user.id
                @user.access_token = Devise.friendly_token.first(35)
                @user.save
                doorkeeper_token.resource_owner_id = @user.id
                present @user.access_token
                # client should use this token to user. But server knows the user through the doorkeeper_token
                # When accessing ... hmmmmmmm
              else
                # invalid password
                present "ERROR: Invalid Credentials #{email}"
              end
            end
          end
        end
      end
      resource :users do
        namespace 'signup' do
          desc 'Sign Up'
          post do
            # Create User using Params
            email = params[:uemail].downcase
            password = params[:upassword]
            # Check if this Email exists
            existing_user = User.find_by_email(email)
            unless existing_user.present?
              #no user with this email
              #create users
              current_user = User.create(:name => email, :password => password, :email => email)
              current_user.access_token = Devise.friendly_token.first(65)
              current_user.save
              doorkeeper_token.resource_owner_id = current_user.id
              #present "Successfully Created Account"
              present current_user.access_token
              # With Above, we can find the user by the client access_token(doorkeeper_token)
            else
              present "ERROR: There is already a user by this email"
            end

          end
        end
      end

    end
  end
end
