require 'doorkeeper/grape/helpers'

module API
  module V1
    class Topics < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      resource :topics do
        namespace 'addtopics' do
          desc "Set the User's Topics"
          post do
            token = params[:utoken]
            topics = params[:utopics]
            #find user by token
            current_user = User.find_by_access_token(token)
            #make sure current_user exists
            if current_user
              # found user, find and add topics (by ids)
              array_of_topics = topics.split(",").map(&:to_i)
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
      end

    end
  end
end
