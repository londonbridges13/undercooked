require 'doorkeeper/grape/helpers'

module API
  module V2
    class Suggestions < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      helpers SuggestionsHelper

      resource :suggestions do
        namespace 'create_suggestions_for_topic' do
          desc ""
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)
            create_suggestions_for_topic(topic)
          end
        end
      end


      # resource :suggestions do
      #   namespace 'suggested_article_count' do
      #     desc ""
      #     post do
      #       id = params[:utopic]
      #       topic = Topic.find_by_id(id)
      #
      #       present topic.suggestions.count
      #     end
      #   end
      # end



      resource :suggestions do
        namespace 'display_suggested_articles' do
          desc ""
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            suggested_articles = []
            topic.suggestions.each do |s|
              if s.article
                unless suggested_articles.include? s.article or s.rejected == true or s.article.publish_it == false
                  if s.reason == "Resource"
                    s.article.display_topic = s.reason
                  else
                    s.article.display_topic = s.evidence
                  end
                  suggested_articles.push(s.article)
                end
              end
            end

            present suggested_articles
          end
        end
      end

      resource :suggestions do
        namespace 'accept_all_suggestions' do
          desc ""
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            accept_all_suggestions_for topic

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

            t_id = params[:utopic]
            a_id = params[:uarticle]

            topic = Topic.find_by_id(t_id)
            article = Article.find_by_id(a_id)

            suggestions = topic.suggestions & article.suggestions # RETURNS AN ARRAY OF COMMON VALUES
            suggestions.each do |s|
              s.rejected = true
              s.save
            end
            suggestion = suggestions.first

            suggestion.rejected = true
            suggestion.save
            # We don't mess with the actual article because it may be used for another topic.
            present suggestion
          end
        end
      end


    end
  end
end
