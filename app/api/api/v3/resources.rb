require 'doorkeeper/grape/helpers'

module API
  module V3
    class Resources < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json


      resource :resources do
        namespace 'get_resource' do
          desc ""
          post do
            id = params[:uarticle]
            article = Article.find_by_id(id)

            display = Article.new(id: article.resource.id, title: article.resource.title, article_image_url: article.resource.image.url)
            present display #article.resource
          end
        end
      end

      resource :resources do
        namespace 'display_resource_articles' do
          desc "Query All Resource's Articles"
          post do
            id = params[:uresource]
            resource = Resource.find_by_id(id)#, with: Entity::V3::ArticlesEntity
            articles = resource.articles.where(:publish_it => true).order(article_date: :desc).all
            articles.each do |a|
              if a.desc == ""
                a.desc = "From #{a.resource.title}"
              end
            end
            present articles.page params[:page]
          end
        end
      end


      resource :resources do
        namespace 'count_channel_posts' do
          desc ""
          post do
            id = params[:uresource]
            resource = Resource.find_by_id(id)
            present resource.count_posts
          end
        end
      end

      resource :resources do
        namespace 'count_channel_followers' do
          desc ""
          post do
            id = params[:uresource]
            resource = Resource.find_by_id(id)
            present resource.count_followers
          end
        end
      end

      resource :resources do
        namespace 'glimpse_channel_content' do
          desc ""
          post do
            id = params[:uresource]
            resource = Resource.find_by_id(id)
            present resource.share_alittle
          end
        end
      end


    #Follow System

      resource :resources do
        namespace 'follow_channel' do
          desc "self"
          post do
            id = params[:uresource]
            channel = Resource.find_by_id(id)#, with: Entity::V3::ArticlesEntity
            token = params[:utoken]
            user = User.find_by_token(token)
            if user
              user.follow_channel! channel.id
              present "Successfully Followed #{channel.title}"
            end
          end
        end
      end

      resource :resources do
        namespace 'unfollow_channel' do
          desc "self"
          post do
            id = params[:uresource]
            channel = Resource.find_by_id(id)#, with: Entity::V3::ArticlesEntity
            token = params[:utoken]
            user = User.find_by_token(token)
            if user
              user.unfollow_channel! channel.id
              present "Successfully Unfollowed #{channel.title}"
            end
          end
        end
      end

      resource :resources do
        namespace 'is_following_channel' do
          desc "self"
          post do
            id = params[:uresource]
            channel = Resource.find_by_id(id)#, with: Entity::V3::ArticlesEntity
            token = params[:utoken]
            user = User.find_by_token(token)
            if user
              if user.following_channel? channel.id
                present "true"
              else
                present "false"
              end
            else
              present "ERROR: COULDN'T FIND USER"
            end
          end
        end
      end




    end
  end
end
