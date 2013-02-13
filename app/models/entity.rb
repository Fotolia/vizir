class Entity < ActiveRecord::Base
  attr_accessible :name

  validates :name,
    :uniqueness => true,
    :presence => true

  has_many :instances, :inverse_of => :entity, :dependent => :destroy
  has_many :metrics, :through => :instances
  #has_many :graphs, :finder_sql => Proc.new { %Q(SELECT DISTINCT graphs.id, graphs.*, instances.* FROM graphs LEFT JOIN graphs_instances ON graphs_instances.graph_id = graphs.id LEFT JOIN instances ON graphs_instances.instance_id = instances.id WHERE instances.entity_id=#{id}) }
  has_many :graphs, :through => :instances, :select => 'DISTINCT graphs.id, graphs.*'
end
