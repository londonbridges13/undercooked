require 'bcrypt'

class User < ActiveRecord::Base


  # attr_accessor :password
  validates_uniqueness_of :email
  validates_presence_of :email
  # validates_uniqueness_of :access_token

  has_and_belongs_to_many :topics
  has_and_belongs_to_many :articles
  has_many :feedbacks
  has_many :timers

  #Image
  has_attached_file :image, styles: { medium: "200x200>", thumb: "90x90>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/



  # Follow System, Followers, Following
  def count_following
    follow_count = Relationship.where(:follower_id => self.id).count
    return follow_count
  end

  def display_following
    following = []
    relationships = Relationship.where(:follower_id => self.id)
    relationships.each do |r|
      # present both channels and users (at the moment only channels)
      if r.is_channel
        #it's a channel, add to following
        channel = Resource.find_by_id(r.followed_id)
        following.push channel
      else
        # it's a user, add to following
        user = User.find_by_id(r.followed_id)
        following.push user
      end
    end
    return following
  end
  # Follow System for Channels (Resources)
  def following_channel?(channel_id)
    if Relationship.where(:is_channel => true).where(:follower_id => self.id).find_by_followed_id(channel_id)
      return true
    else
      return false
    end
  end

  def follow_channel!(channel_id)
    follow = Relationship.new(followed_id: channel_id, follower_id: self.id, is_channel: true)
    p follow.followed_id
    p follow.follower_id
    p follow.is_channel

    if follow.save!
      return true
    else
      return false
    end
  end

  def unfollow_channel!(channel_id)
    if Relationship.where(:is_channel => true).where(:follower_id => self.id).find_by_followed_id(channel_id).destroy
      return true
    else
      return false
    end
  end


  # Follow System for User (If Used)
  def following_user?(user_id)
    if Relationship.where(:is_channel => false).where(:follower_id => self.id).find_by_followed_id(user_id)
      return true
    else
      return false
    end
  end

  def follow_user!(user_id)
    follow = Relationship.new(followed_id: channel_id, follower_id: self.id, is_channel: false)
    p follow.followed_id
    p follow.follower_id
    p follow.is_channel

    if follow.save!
      return true
    else
      return false
    end
  end

  def unfollow_user!(user_id)
    if Relationship.where(:is_channel => false).where(:follower_id => self.id).find_by_followed_id(user_id).destroy
      return true
    else
      return false
    end
  end



  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
