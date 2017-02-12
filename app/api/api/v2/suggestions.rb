require 'doorkeeper/grape/helpers'

module API
  module V2
    class Suggestions < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json

      resource :suggestions do
        namespace 'create_suggestions_for_topic' do
          desc ""
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity


            present
          end
        end
      end


      resource :suggestions do
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


      resource :suggestions do
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


      resource :suggestions do
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
