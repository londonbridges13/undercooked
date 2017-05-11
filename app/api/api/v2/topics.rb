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
            #USING TAGS FOR KEYWORDS, BECAUSE ARRAYS ARE FUCKED IN RAILS
            id = params[:utopic]
            keywords = params[:keywords]#.downcase

            topic = Topic.find_by_id(id)
            topic.tags.clear
            array_of_keywords = keywords

            array_of_keywords.each do |k|
              k.downcase!
              k_tag = Tag.find_or_create_by(:title => k)
              unless topic.tags.include? k_tag
                topic.tags.push(k_tag)
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
            #USING TAGS FOR KEYWORDS, BECAUSE ARRAYS ARE FUCKED IN RAILS
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            # PRESENT LIKE A TAG SO THAT THERE ARE NO ISSUES IN CLIENT APP
            keywords = []
            if topic
              topic.tags.each do |k|
                keyword = k#Tag.find_or_create_by(:title => k)
                keywords.push(keyword)
              end
            end
            present keywords
          end
        end
      end


      resource :topics do
        namespace 'set_proofs' do
          desc "Self"
          post do
            #USING TAGS FOR KEYWORDS, BECAUSE ARRAYS ARE FUCKED IN RAILS
            id = params[:utopic]
            proofs = params[:proofs]#.downcase

            topic = Topic.find_by_id(id)
            topic.auto_proofs.clear
            topic.save
            array_of_proofs = proofs

            array_of_proofs.each do |proof|
              proof.downcase!
              unless topic.auto_proofs.include? proof
                topic.auto_proofs.push(proof)
                topic.save
              end
            end

            present topic
          end
        end
      end


      resource :topics do
        namespace 'get_topic_proofs' do
          desc "Query a Topic's Proofs"
          post do
            #USING TAGS FOR KEYWORDS, BECAUSE ARRAYS ARE FUCKED IN RAILS
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            # PRESENT LIKE A TAG SO THAT THERE ARE NO ISSUES IN CLIENT APP
            proofs = []
            if topic
              topic.auto_proofs.each do |proof|
                proof_tag = Tag.new(:title => proof) #converting into tag for content app
                proofs.push(proof_tag)
              end
            end
            present proofs
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
            ContentWorker.perform_async(id) # this will grab new icon
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
