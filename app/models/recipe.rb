class Recipe < ActiveRecord::Base
  validates_uniqueness_of :article

  has_many :recipe_ingredients
  has_many :instructions
  belongs_to :article
end
