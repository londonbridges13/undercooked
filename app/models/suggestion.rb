class Suggestion < ActiveRecord::Base

  validates_presence_of :reason
  validates_presence_of :evidence

  belongs_to :topic
  belongs_to :article
  has_one :auto_publishing


end
