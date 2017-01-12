require 'doorkeeper/grape/helpers'

module API
  module V1
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
            # if a topic = Featured, remove it from list of presented topics. Because featured isnt an option
            display_topics = []
            topics.each do |t|
              unless t.title == "Featured"
                #add to display_topics
                display_topics.push(t)
              end
            end
            present display_topics
          end
        end
      end

      resource :topics do
        namespace 'addtopics' do
          desc "Set the User's Topics"
          post do
            token = params[:utoken]
            topics = params[:utopics]
            #find user by token
            current_user = User.find_by_access_token(token)
              # find and add topics (by ids)
              array_of_topics = topics #topics.split(",").map(&:to_i)
              array_of_topics.each do |t|
                a_topic = Topic.find_by_id(t)
                unless current_user.topics.include? a_topic
                  # Don't want to add a topic that already exists
                  current_user.topics.push(a_topic)
                  present "Successfully added topics"
                end
              end
          end
        end
      end

      # resource :topics do
      #   namespace 'add_one_topic' do
      #     desc "When User purchases another topic. Set the User's Topics"
      #     post do
      #       token = params[:utoken]
      #       topics = params[:utopics]
      #       #find user by token
      #       current_user = User.find_by_access_token(token)
      #       #make sure current_user exists
      #       if current_user
      #         # found user, find and add topics (by ids)
      #         array_of_topics = topics.split(",").map(&:to_i)
      #         array_of_topics.each do |t|
      #           a_topic = Topic.find_by_id(t)
      #           unless current_user.topics.include? a_topic
      #             # Don't want to add a topic that already exists
      #             current_user.topics.push(a_topic)
      #             present "Successfully added topics"
      #           end
      #         end
      #       end
      #     end
      #   end
      # end

      resource :topics do
        namespace 'swap_topics' do
          desc "Query User's Topics"
          post do
            token = params[:utoken]
            oldtopic_id = params[:oldtopic]
            newtopic_id = params[:newtopic]
            newtopic = Topic.find_by_id(newtopic_id)
            oldtopic = Topic.find_by_id(oldtopic_id)
            #find user by token
            current_user = User.find_by_access_token(token)
            #make sure current_user exists
            if current_user
              if current_user.topics.include? oldtopic
                current_user.topics.delete(oldtopic)
                unless current_user.topics.include? newtopic
                  current_user.topics.push(newtopic)
                  present "Successfully added Topic"
                end
              end
            end

          end
        end
      end

      resource :topics do
        namespace 'get_swappable_topics' do
          desc "Query All that are not User's Topics"
          post do
            token = params[:utoken]
            #find user by token
            current_user = User.find_by_access_token(token)
            #make sure current_user exists
            if current_user
              all_topics = Topic.all
              swappable_topics = [] # swappable topics
              all_topics.each do |t|
                unless current_user.topics.include? t
                  # add to display array
                  swappable_topics.push(t)
                end
              end
              present swappable_topics
            end

          end
        end
      end

      resource :topics do
        namespace 'remove_a_topic' do
          desc "Remove one of User's Topics"
          post do
            token = params[:utoken]
            topic = params[:utopic]
            #find user by token
            current_user = User.find_by_access_token(token)
            #make sure current_user exists
            if current_user
              # found user, find and add topics (by ids)
                a_topic = Topic.find_by_id(topic)
                if current_user.topics.include? a_topic
                  # Don't want to add a topic that already exists
                  current_user.topics.delete(a_topic)
                  present "Successfully added topics"
                end

            end
          end
        end
      end

      resource :topics do
        namespace 'get_topics' do
          desc "Query User's Topics"
          post do
            token = params[:utoken]
            #find user by token
            current_user = User.find_by_access_token(token)
            #make sure current_user exists
            if current_user
              present current_user.topics
            end

          end
        end
      end

      resource :topics do
        namespace 'display_topic_articles' do
          desc "Query All Topic's Articles"
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            present topic.articles.where(:publish_it => true).order(created_at: :desc).limit(20).all
          end
        end
      end

      resource :topics do
        namespace 'get_topic_image' do
          desc "Query User's Topics"
          post do
            # token = params[:utoken]
            id = params[:utopic]

            #find user by token
            # current_user = User.find_by_access_token(token)
            #make sure current_user exists
            # if current_user
              t = Topic.find_by_id(id)
                # present image_url
                present t.image.url
            # end

          end
        end
      end



      resource :topics do
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





    end
  end
end
