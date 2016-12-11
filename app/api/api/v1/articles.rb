module API
  module V1
    class Articles < Grape::API
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
