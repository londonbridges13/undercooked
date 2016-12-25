class Product < ActiveRecord::Base
  # validates_uniqueness_of :product_url
  validates_presence_of :product_url
  validates_presence_of :title
  validates_presence_of :description
  # validates_presence_of :image
  has_and_belongs_to_many :topics
  has_and_belongs_to_many :tags


  has_attached_file :image, styles: { medium: "200x200>", thumb: "90x90>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

end
