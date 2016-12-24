require 'doorkeeper/grape/helpers'

module API
  module V2
    class Resources < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json

      resource :resources do
        namespace 'display_resource' do
          desc "Query a Resource"
          post do
            id = params[:uarticle]
            article = Article.find_by_id(id)
            resource = article.resource
            present resource
            
          end
        end
      end



    end
  end
end
