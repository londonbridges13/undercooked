class ContentWorker
  include SuckerPunch::Job
  # workers 1

  def perform(topic_id)
    ActiveRecord::Base.connection_pool.with_connection do
      topic = User.find_by_id(topic_id)
      topic.name = "James Mackey"
      topic.save
    end
  end

end
