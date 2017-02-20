require 'doorkeeper/grape/helpers'

module API
  module V1
    class Feedbacks < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json

      resource :feedbacks do
        namespace 'feedback' do
          desc "Sends feedback and suggestion from user"
          post do
              # find Article
              suggestion = params[:suggestion]
              feedback = params[:feedback]

              if feedback
                #create feedback here (message, suggestion)
                new_feedback.new(:message => feedback, :suggestion => suggestion)
                new_feedback.save
                present "Saved"
              else
                present "Error"
              end
          end
        end
      end

    end
  end
end
