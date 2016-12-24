require 'doorkeeper/grape/helpers'

module API
  module V1
    class Articles < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      helpers ArticlesHelper

      resource :articles do
        namespace 'handpicked_articles' do
          desc "Query Articles based on User's Topics"
          post do
            token = params[:utoken]
            current_user = User.find_by_access_token(token)
            if current_user
              # get articles
              topics = current_user.topics.shuffle
              get_articles_from(topics)
            else
              present "ERROR: No User Found"
            end
          end
        end
      end

      resource :articles do
        namespace 'likedarticles' do
          desc "Query Articles based on User's Topics"
          post do
            current_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            unless current_user
              token = params[:utoken]
              current_user = User.find_by_access_token(token)
            end
            if current_user.present?
              # display articles that the user liked.
              present current_user.articles
              # present User.first#Article.order(title: :asc), with: Entity::V1::ArticlesEntity
            end
          end
        end
      end

      resource :articles do
        namespace 'extra' do
          desc "Query Articles based on User's Topics"
          get do
            current_user = User.find_by
            present User.first#Article.order(title: :asc), with: Entity::V1::ArticlesEntity
          end
        end
      end


    end
  end
end