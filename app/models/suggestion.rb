class Suggestion < ActiveRecord::Base

  validates_presence_of :reason
  validates_presence_of :evidence

  has_one :article
  belongs_to :topic


end
