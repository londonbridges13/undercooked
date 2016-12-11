require 'doorkeeper/grape/helpers'

module API
  module V1
    class Articles < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      resource :articles do
        desc "Query Articles based on User's Topics"
        get do
          present Article.order(title: :asc), with: Entity::V1::ArticlesEntity
        end
      end
    end
  end
end
