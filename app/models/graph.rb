class Graph < ActiveRecord::Base
  attr_accessible :name

  validates :name,
    :presence => true

  has_and_belongs_to_many :instances

  scope :w_entity,


  def load_defs
    Vizir::DSL[:graph].each do |graph_def|
      graph = new(:name => graph_def[:name])
      case graph_def[:scope]
        when :entity_instance
          nil # noop for now
        when :entity
          Entity.all.each do |entity|
            graph.instances = Instance.join_assocs.where(:entities => {:id => entity.id}, :metrics => {:name => graph_def[:metrics]})
          end
        else
          nil # noop for now
      end
    end
  end

  def fetch_values(start, finish)
    instances.map {|i| i.fetch_values(start, finish)}
  end
end
