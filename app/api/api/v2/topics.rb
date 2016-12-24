require 'doorkeeper/grape/helpers'

module API
  module V2
    class Topics < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json

      resource :topics do
        namespace 'display_topics' do
          desc "Query All Topics"
          post do
            topics = Topic.all#, with: Entity::V1::ArticlesEntity
            present topics
          end
        end
      end


      resource :topics do
        namespace 'display_topic_articles' do
          desc "Query All Topic's Articles"
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            present topic.articles.limit(20).all
          end
        end
      end

      resource :topics do
        namespace 'get_topic_info' do
          desc "Query a Topic"
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            present topic
          end
        end
      end

      resource :topics do
        namespace 'get_topic_tags' do
          desc "Query a Topic's Tags"
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            present topic.tags
          end
        end
      end

      resource :topics do
        namespace 'update_title_desc' do
          desc "Update Desc and Title of a Topic"
          post do
            id = params[:utopic]
            title = params[:title]
            desc = params[:desc]

            topic = Topic.find_by_id(id)
            topic.description = desc
            topic.title = title
            topic.save
            present topic
          end
        end
      end

      resource :topics do
        namespace 'update_tags' do
          desc "Update Desc and Title of a Topic"
          post do
            id = params[:utopic]
            tags = params[:tags]#.downcase

            topic = Topic.find_by_id(id)
            topic.tags.delete_all
            array_of_tags = tags

            array_of_tags.each do |t|
              tag = Tag.find_or_create_by(title: t.downcase!)
              unless topic.tags.include? tag
                topic.tags.push(tag)
              end
            end
            present topic
          end
        end
      end

    end
  end
end
