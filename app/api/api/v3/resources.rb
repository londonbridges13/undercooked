require 'doorkeeper/grape/helpers'

module API
  module V3
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

            display = Article.new(title: article.resource.title, article_image_url: article.resource.image.url)
            present display #article.resource
          end
        end
      end


    end
  end
end
