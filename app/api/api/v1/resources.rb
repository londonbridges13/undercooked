require 'doorkeeper/grape/helpers'

module API
  module V1
    class Resources < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json


      resource :resources do
        namespace 'get_resource' do
          desc ""
          post do
            id = params[:uarticle]
            article = Article.find_by_id(id)

            present article.resource.title
          end
        end
      end


    end
  end
end
