class Article < ActiveRecord::Base
  validates_uniqueness_of :article_url
  validates_presence_of :resource
  validates_presence_of :article_url
  before_create :check_for_image
  belongs_to :resource
  has_and_belongs_to_many :topics
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags

  #Image
  has_attached_file :image, styles: { medium: "200x200>", thumb: "90x90>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/


private
  def check_for_image
    # Check for image, if no image. Use the resource image
    unless self.article_image_url.present?
      # Set resource.image.url
      self.article_url = resource.image.url
    end
  end


end
