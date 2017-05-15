module API
  module V2
    class Base < Grape::API
      format :json
      default_format :json

      prefix 'api'
      version 'v2', using: :path


      mount V2::Resources
      mount V2::Articles
      mount V2::AutoPublishings
      # mount V2::Products
      mount V2::Topics
      mount V2::Suggestions
      # mount V2::Users
      # mount V2::Tags

    end
  end
end
