class ContentWorkerController < ApplicationController
  include SuckerPunch::ContentWorker
  workers 1

  def perform(topic_id)
      present topic_id
  end
end
