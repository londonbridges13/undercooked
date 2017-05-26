require 'doorkeeper/grape/helpers'

module API
  module V3
    class Resources < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      helpers ResourcesHelper


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
        namespace 'my_channels' do
          desc ""
          post do
            token = params[:utoken]
            user = User.find_by_access_token(token)
            following = user.display_following

            channels = []
            following.each do |f|
              # convert to article, easier to present
              channel = Article.new(id: f.id, title: f.title, article_image_url: f.image.url)
              channels.push channel
            end

            present channels #article.resource
          end
        end
      end


      resource :resources do
        namespace 'recommend_channels' do
          desc "Recommend Channels Based on Topics"
          post do
            topic_ids = params[:utopics]
            topics = []
            topic_ids.each do |t|
              topic = Topic.find_by_id(t)
              if topic
                topics.push topic
              end
            end
            recommend_channels_by_topics(topics)
          end
        end
      end


      resource :resources do
        namespace 'get_channel_info' do
          desc ""
          post do
            id = params[:uchannel]
            channel = Resource.find_by_id(id)

            display = Article.new(id: channel.id, title: channel.title, article_image_url: channel.image.url)
            present display #article.resource
          end
        end
      end

      resource :resources do
        namespace 'display_resource_articles' do
          desc "Query All Resource's Articles"
          post do
            id = params[:uchannel]
            resource = Resource.find_by_id(id)#, with: Entity::V3::ArticlesEntity
            articles = resource.articles.order(article_date: :desc).limit(200).all
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
            id = params[:uchannel]
            resource = Resource.find_by_id(id)
            present resource.count_posts
          end
        end
      end

      resource :resources do
        namespace 'count_channel_followers' do
          desc ""
          post do
            id = params[:uchannel]
            resource = Resource.find_by_id(id)
            present resource.count_followers
          end
        end
      end

      resource :resources do
        namespace 'glimpse_channel_content' do
          desc ""
          post do
            id = params[:uchannel]
            resource = Resource.find_by_id(id)
            present resource.share_alittle
          end
        end
      end

      resource :resources do
        namespace 'channel_description' do
          desc ""
          post do
            id = params[:uchannel]
            resource = Resource.find_by_id(id)
            present resource.desc
          end
        end
      end


    #Follow System

      resource :resources do
        namespace 'follow_channel' do
          desc "self"
          post do
            id = params[:uchannel]
            channel = Resource.find_by_id(id)#, with: Entity::V3::ArticlesEntity
            token = params[:utoken]
            user = User.find_by_access_token(token)
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
            id = params[:uchannel]
            channel = Resource.find_by_id(id)#, with: Entity::V3::ArticlesEntity
            token = params[:utoken]
            user = User.find_by_access_token(token)
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
            id = params[:uchannel]
            channel = Resource.find_by_id(id)#, with: Entity::V3::ArticlesEntity
            token = params[:utoken]
            user = User.find_by_access_token(token)
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
