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
            email = params[:uemail].downcase
            password = params[:upassword]
            token = params[:utoken]
              # use email address to sign in
              @user = User.find_by_email(email)
              if @user == nil
                @user = User.find_by_access_token(token)
              end
              if @user and @user.valid_password? password
                # give user a new personal access_token, and set doorkeeper_token.resource_owner_id = @user.id
                @user.access_token = Devise.friendly_token.first(35)
                @user.save
                doorkeeper_token.resource_owner_id = @user.id
                present @user
                # client should use this token to user. But server knows the user through the doorkeeper_token
                # When accessing ... hmmmmmmm
              else
                # invalid password
                present "ERROR: Invalid Credentials #{token}"
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
              present current_user
              # With Above, we can find the user by the client access_token(doorkeeper_token)
            else
              present "ERROR: There is already a user by this email"
            end
          end
        end
      end

      resource :users do
        namespace 'profile' do
          desc 'Get Profile Information'
          post do
            token = params[:utoken]
            # Check if this Token exists
            existing_user = User.find_by_access_token(token)
            if existing_user == nil
              existing_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            end
            if  existing_user.present?
              present existing_user
            else
              present "ERROR: Cannot find user by token, please sign in again"
            end
          end
        end
      end

      resource :users do
        namespace 'profile_pic' do
          desc 'Get Profile Information'
          post do
            token = params[:utoken]
            # Check if this Token exists
            existing_user = User.find_by_access_token(token)
            if existing_user == nil
              existing_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            end
            if  existing_user.present?
              present existing_user.image
            else
              present "ERROR: Cannot find user by token, please sign in again"
            end
          end
        end
      end

      resource :users do
        namespace 'update_profile_pic' do
          desc 'Get Profile Information'
          post do
            token = params[:utoken]
            # Check if this Token exists
            existing_user = User.find_by_access_token(token)
            if existing_user == nil
              existing_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            end
            if existing_user
              # set the image
              @picture = existing_user.image

                image_file = Paperclip.io_adapters.for(params[:photo_path])
                image_file.original_filename = params[:file_name]
                image_file.content_type = "image/jpeg"
                @picture = image_file
                existing_user.image = @picture
                existing_user.save

                present "Successfully Updated Profile Picture"

            else
              present "ERROR: Cannot find user by token, please sign in again"
            end
          end
        end
      end



      resource :users do
        namespace 'topics' do
          desc "Get User's  Topics"
          post do
            token = params[:utoken]
            # Check if this Token exists
            existing_user = User.find_by_access_token(token)
            if existing_user == nil
              existing_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            end
            if  existing_user.present?
              present existing_user.topics
            else
              present "ERROR: Cannot find user by token, please sign in again"
            end
          end
        end
      end

      resource :users do
        namespace 'did_user_like_article' do
          desc "Check if user liked Article"
          post do
              # find Article
              id = params[:uarticle]
              article = Article.find_by_id(id)
              token = params[:utoken]
              current_user = User.find_by_access_token(token)

              if current_user.articles.include? article
                # user liked this article
                present true
              else
                present false
              end

          end
        end
      end


      resource :users do
        namespace 'add_reading_time' do
          desc ""
          post do
              # find Topic
              # id = params[:utopic]
              # topic = Topic.find_by_id(id)

              a_id = params[:uarticle]
              article = Article.find_by_id(a_id)

              token = params[:utoken]
              time = params[:utimer].to_i # number of seconds
              user = User.find_by_access_token(token)

              topics = []
              article.topics.each do |t|
                if user.topics.include? t
                  topics.push t
                end
              end

              topics.each do |topic|
                # update timers for all of these topics
                # check if user has this topic, nvm already did

                if user.present? and user.topics.include? topic
                  # user liked this topic
                  user.timers.each do |ti|
                    if topic.timers.include? ti
                      # add time to this timer
                      if ti.seconds.present?
                        ti.seconds += time
                        ti.save
                        present "success"
                      else
                        ti.seconds = time
                        ti.save
                        present "success"
                      end
                    end
                  end

                else
                  present "no topic or no user"
                end

              end

          end
        end
      end


      resource :users do
        namespace 'edit_name' do
          desc 'Edit Profile Information'
          post do
            token = params[:utoken]
            name = params[:uname]
            # Check if this Token exists
            existing_user = User.find_by_access_token(token)
            if existing_user == nil
              existing_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            end
            if  existing_user.present?
              existing_user.name = name
              existing_user.save
              present existing_user
            else
              present "ERROR: Cannot find user by token, please sign in again"
            end
          end
        end
      end

      resource :users do
        namespace 'edit_password' do
          desc 'Edit Profile Information'
          post do
            token = params[:utoken]
            new_password = params[:newpassword]
            old_password = params[:oldpassword]
            # Check if this Token exists
            existing_user = User.find_by_access_token(token)
            if existing_user == nil
              existing_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            end
            if  existing_user.present?
              if existing_user.valid_password? old_password
                existing_user.password = new_password
                existing_user.save
                present existing_user
              else
                present "Invalid Password"
              end
            else
              present "ERROR: Cannot find user by token, please sign in again"
            end
          end
        end
      end







    end
  end
end
