class Recipe < ActiveRecord::Base
  has_many :recipe_ingredients
  has_many :instructions
  belongs_to :article
end
