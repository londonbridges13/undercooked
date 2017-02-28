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
              token = params[:utoken]

              user = User.find_by_access_token(token)

              if feedback
                #create feedback here (message, suggestion)
                new_feedback = user.feedbacks.build(:message => feedback, :suggestion => suggestion)
                new_feedback.save
                present "Saved"
              else
                present "Error"
              end
          end
        end
      end

      resource :feedbacks do
        namespace 'did_user_give_feedback' do
          desc "Checks for  feedback from user"
          post do
              # find Article
              token = params[:utoken]

              user = User.find_by_access_token(token)

              if user
                if user.feedbacks.count > 0
                  present "yes" # yes the user has given feedback
                else
                  present "no" # no the user has not given feedback
                end
              else
                present "no user"
              end
          end
        end
      end

    end
  end
end
