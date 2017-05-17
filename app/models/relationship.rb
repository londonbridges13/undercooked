class Relationship < ActiveRecord::Base
  validates_presence_of :follower_id
  validates_presence_of :followed_id
  validates_presence_of :is_channel

  belongs_to :user
end
