module API
  module V1
    class Base < Grape::API
      format :json
      default_format :json

      prefix 'api'
      version 'v1', using: :path


      mount V1::Resources
      mount V1::Articles
      # mount V1::Products
      mount V1::Topics
      mount V1::Users
      mount V1::Feedbacks
      # mount V1::Tags

    end
  end
end
