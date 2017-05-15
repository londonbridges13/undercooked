module API
  module V3
    class Base < Grape::API
      format :json
      default_format :json

      prefix 'api'
      version 'v3', using: :path


      mount V3::Resources
      mount V3::Articles
      mount V3::Topics
      mount V3::Users
      mount V3::Feedbacks
      # mount V3::Tags
      # mount V3::Products

    end
  end
end
