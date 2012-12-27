class Entity < ActiveRecord::Base
  attr_accessible :name

  validates :name,
    :uniqueness => true,
    :presence => true

  has_many :instances
  has_many :metrics, :through => :instances
end
