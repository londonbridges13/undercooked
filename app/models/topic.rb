class Topic < ActiveRecord::Base
  validates_uniqueness_of :title
  validates_presence_of :description
  validates_presence_of :title
  validates_presence_of :image
  has_and_belongs_to_many :articles
  has_and_belongs_to_many :resources
  has_and_belongs_to_many :products
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  has_many :suggestions
  has_many :timers

  has_attached_file :image, styles: { medium: "200x200>", thumb: "90x90>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/



  #Scopes
    scope :viewable_topics, -> { where.not(id: 12).all } # skips the featured topic


end
