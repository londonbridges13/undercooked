class Tag < ActiveRecord::Base
  validates_uniqueness_of :title
  validates_presence_of :title
  has_and_belongs_to_many :topics
  has_and_belongs_to_many :articles
  has_and_belongs_to_many :resources
  has_and_belongs_to_many :products

end
