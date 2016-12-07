class Resource < ActiveRecord::Base
  has_attached_file :image, styles: { medium: "200x200>", thumb: "90x90>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  has_many :articles 

end
