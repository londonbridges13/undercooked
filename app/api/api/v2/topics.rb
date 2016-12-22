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



    end
  end
end
