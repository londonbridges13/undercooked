require 'doorkeeper/grape/helpers'

module API
  module V2
    class Topics < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      helpers TopicsHelper

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
              t.downcase!
              tag = Tag.find_or_create_by(title: t)
              unless topic.tags.include? tag
                topic.tags.push(tag)
              end
            end
            present topic
          end
        end
      end


      resource :topics do
        namespace 'set_keywords' do
          desc "Self"
          post do
            id = params[:utopic]
            keywords = params[:keywords]#.downcase

            topic = Topic.find_by_id(id)
            topic.keywords.clear
            array_of_keywords = keywords

            array_of_keywords.each do |k|
              k.downcase!
              unless topic.keywords.include? k
                topic.keywords.push(k)
                topic.save
              end
            end

            present topic
          end
        end
      end


      resource :topics do
        namespace 'get_topic_keywords' do
          desc "Query a Topic's Keywords"
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            # PRESENT LIKE A TAG SO THAT THERE ARE NO ISSUES IN CLIENT APP
            keywords = []
            topic.keywords.each do |k|
              keyword = Tag.new(:title => k)
              keywords.push(keyword)
            end
            present keywords
          end
        end
      end


      resource :topics do
        namespace 'get_new_articles_from_topic' do
          desc "self"
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            #find_new_articles_from_topic(topic)
          end
        end
      end






#Suggestions delete below


      resource :topics do
        namespace 'create_suggestions_for_topic' do
          desc ""
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity


            present
          end
        end
      end


      resource :topics do
        namespace 'display_suggested_articles' do
          desc ""
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            suggested_articles = []
            topic.suggestions.each do |a|
              unless suggested_articles.include? a
                suggested_articles.push(a.article)
              end
            end

            present suggested_articles
          end
        end
      end


      resource :topics do
        namespace 'accept_suggested_article' do
          desc ""
          post do
            s_id = params[:usuggestion]
            suggestion = Suggestion.find_by_id(s_id)

            suggestion.rejected = false
            suggestion.save

            suggestion.article.publish_it = true
            suggestion.article.save

            present suggestion.article
          end
        end
      end


      resource :topics do
        namespace 'reject_suggested_article' do
          desc ""
          post do

            s_id = params[:usuggestion]
            suggestion = Suggestion.find_by_id(s_id)

            suggestion.rejected = true
            suggestion.save
            # We don't mess with the actual article because it may be used for another topic.
            present suggestion.article
          end
        end
      end




    end
  end
end
