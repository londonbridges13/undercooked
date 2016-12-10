class User < ActiveRecord::Base
  validates_uniqueness_of :email
  validates_presence_of :email

  has_and_belongs_to_many :topics
  has_and_belongs_to_many :articles

  #Image
  has_attached_file :image, styles: { medium: "200x200>", thumb: "90x90>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
