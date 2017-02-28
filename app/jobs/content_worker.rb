class ContentWorkerController
  include SuckerPunch::Job
  # workers 1

  def perform(topic_id)
    ActiveRecord::Base.connection_pool.with_connection do
      topic = Topic.find_by_id(topic_id)
      present topic_id
    end
  end

end
