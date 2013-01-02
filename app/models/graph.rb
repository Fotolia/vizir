class Graph < ActiveRecord::Base
  attr_accessible :name
  attr_accessor :title, :unit, :layout

  validates :name,
    :presence => true

  has_and_belongs_to_many :instances

  after_find do |graph|
    graph.dsl_override
  end

  scope :w_entity,
    includes(:instances => :entity)

  def self.load_defs
    Vizir::DSL[:graph].each do |graph_def|
      scope = graph_def[:scope]
      case scope
      when nil
        nil # noop for now
      when :entity
        Entity.all.each do |entity|
          graph = new(:name => graph_def[:name])
          graph.instances = Instance.join_assocs.where(:entities => {:id => entity.id}, :metrics => {:name => graph_def[:metrics]})
          graph.save!
        end
      else
        Entity.all.each do |entity|
          instances = Hash.new
          Instance.join_assocs.where(:entities => {:id => entity.id}, :metrics => {:name => graph_def[:metrics]}).each do |instance|
            instances[instance.details[scope]] ||= Array.new
            instances[instance.details[scope]] << instance
          end

          instances.each do |key, instance_list|
            graph = new(:name => graph_def[:name])
            graph.instances = instance_list
            graph.save!
          end
        end
      end
    end
  end

  #def get_title
  #  title = name if title.nil?
  #  entities = instances.map {|i| i.entity.name}.uniq
  #  if entities.count == 1
  #    title = "#{entities.first}##{name}"
  #  end
  #end

  def fetch_values(start, finish)
    {
      "title" => title,
      "layout" => layout,
      "metrics" => instances.incl_assocs.map {|i| i.fetch_values(start, finish)}
    }
  end

  protected

  def dsl_override
    graph_defs = Vizir::DSL[:graph]
    graph_def = graph_defs.select {|g| g[:name] == self.name}
    unless graph_def.empty?
      graph_def.first.each do |key, value|
        if self.respond_to?(key)
          self.send("#{key}=", value)
        end
      end
    end
  end
end
