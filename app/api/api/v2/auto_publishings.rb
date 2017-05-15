require 'doorkeeper/grape/helpers'

module API
  module V2
    class AutoPublishings < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      helpers AutoPublishingsHelper

      resource :auto_publishings do
        namespace 'automatically_publish' do
          desc "Self"
          post do

            p "Assessing Suggestions..."
            suggestions = []
            topics = Topic.all.where.not(id: 12) # all ids but 12
            topics.each do |t|
              #add to suggestions
              # this ensures that we are getting the suggestions that have all the data
              t.suggestions.each do |s|
                suggestions.push s
              end
            end
            p suggestions
            suggestions.each do |s|
              # check for suggestions
              p "Assessing Suggestion: #{s.id}"
              automatic_publishing s
            end
          end
        end
      end

    end
  end
end
