class Resource < ActiveRecord::Base
  validates_uniqueness_of :resource_url
  validates_presence_of :resource_url
  validates_presence_of :title
  validates_presence_of :image
  has_many :articles
  has_and_belongs_to_many :topics
  has_and_belongs_to_many :tags


  has_attached_file :image, styles: { medium: "200x200>", thumb: "90x90>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/


  # Follow System, Followers, Following
  def count_followers
    follow_count = Relationship.where(:followed_id => self.id).count
    return follow_count
  end

  # Channel's Content
  def count_posts
    post_count = self.articles.count
    return post_count
  end

  def share_alittle
    # show a glispe of what this channel has to offer, use for suggesting articles
    a_little = self.articles.order('updated_at DESC').limit(5)
    return a_little
  end

end
