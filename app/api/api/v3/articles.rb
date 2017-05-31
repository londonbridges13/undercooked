require 'doorkeeper/grape/helpers'
require 'will_paginate/array'

module API
  module V3
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
              articles = get_handpicked_articles(current_user)
              page = articles.paginate(:page => params[:page], :per_page => 2)
              p page
              present page
              # present articles.page params[:page]
              # topics = current_user.topics.shuffle
              # get_articles_from(topics)
            else
              present "ERROR: No User Found"
            end
          end
        end
      end


      resource :articles do
        namespace 'recommended_articles' do
          desc "Query Articles based on User's Topics"
          post do

            #shuffle articles
            articles = recommended_content
            present articles
          end
        end
      end


      resource :articles do
        namespace 'likedarticles' do
          desc "Query Articles that the User has liked"
          post do
            current_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            unless current_user
              token = params[:utoken]
              current_user = User.find_by_access_token(token)
            end
            if current_user.present?
              # display articles that the user liked.
              present current_user.articles.where(:publish_it => true).order(article_date: :desc).limit(200).all
              # present User.first#Article.order(title: :asc), with: Entity::V1::ArticlesEntity
            end
          end
        end
      end

      resource :articles do
        namespace 'like_an_article' do
          desc "Like an Article"
          post do
            current_user = User.find_by_id(doorkeeper_token.resource_owner_id)
            unless current_user
              token = params[:utoken]
              current_user = User.find_by_access_token(token)
            end
            if current_user.present?
              # find Article
              id = params[:uarticle]
              article = Article.find_by_id(id)
              unless current_user.articles.include? article
                article.users.push(current_user)
              else
                article.users.delete(current_user)
              end
              present article.users.count

            end
          end
        end
      end

      resource :articles do
        namespace 'get_article_like_count' do
          desc "Count Article's likes"
          post do
              # find Article
              id = params[:uarticle]
              article = Article.find_by_id(id)
              present article.users.count

          end
        end
      end





    end
  end
end
