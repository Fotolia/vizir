class Entity < ActiveRecord::Base
  attr_accessible :name

  validates :name,
    :uniqueness => true,
    :presence => true

  has_many :entity_metrics
  has_many :metrics, :through => :entity_metrics
end
