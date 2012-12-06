class Entity < ActiveRecord::Base
  attr_accessible :name

  has_many :entity_metrics
  has_many :metrics, :through => :entity_metrics
end
