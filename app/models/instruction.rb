class Instruction < ActiveRecord::Base
  has_and_belongs_to_many :actions
  belongs_to :recipe 
end
