class Graph < ActiveRecord::Base
  attr_accessible :name
  attr_accessor :title, :unit, :layout, :scope

  validates :name,
    :presence => true

  has_many :graphs_instances
  has_many :instances, :through => :graphs_instances, :order => "graphs_instances.sort"
  has_many :entities, :through => :instances

  after_find do |graph|
    graph.dsl_override
  end

  scope :w_entity,
    includes(:instances => :entity)

  def self.load_defs
    GraphsInstance.destroy_all
    Graph.destroy_all
    Graph.reset_pk_sequence
    Vizir::DSL.data[:graph].each do |graph_def|
      scope = graph_def[:scope]
      case scope
      when nil
        nil # noop for now
      when :entity
        Entity.all.each do |entity|
          graph = create(:name => graph_def[:name])
          Instance.join_assocs.where(:entities => {:id => entity.id}, :metrics => {:name => graph_def[:metrics]}).each do |instance|
            graph.graphs_instances.create(:instance => instance, :sort => graph_def[:metrics].index(instance.metric.name))
          end
        end
      else
        Entity.all.each do |entity|
          instances = Hash.new
          Instance.join_assocs.where(:entities => {:id => entity.id}, :metrics => {:name => graph_def[:metrics]}).each do |instance|
            instances[instance.details[scope]] ||= Array.new
            instances[instance.details[scope]] << instance
          end

          instances.each do |key, instance_list|
            graph = create(:name => graph_def[:name])
            instance_list.each do |instance|
              graph.graphs_instances.create(:instance => instance, :sort => graph_def[:metrics].index(instance.metric.name))
            end
          end
        end
      end
    end
    Instance.wo_graph.each do |instance|
      graph = new(:name => instance.title)
      graph.instances << instance
      graph.save!
    end
  end

  def title
    case scope
    when nil
      instances.first.title
    when :entity
      @title
    else
      replace_vars(@title, instances.first.details)
    end
  end

  def fetch_values(start, finish)
    entity_name = entities.uniq.first.name
    {
      "id" => id,
      "title" => "#{entity_name}/#{title}",
      "layout" => layout,
      "metrics" => instances.incl_assocs.map {|i| i.fetch_values(start, finish)}
    }
  end

  protected

  def dsl_override
    graph_defs = Vizir::DSL.data[:graph]
    graph_def = graph_defs.select {|g| g[:name] == self.name}
    unless graph_def.empty?
      graph_def.first.each do |key, value|
        if self.respond_to?(key)
          val = value.is_a?(String) ? value.dup : value
          self.send("#{key}=", val)
        end
      end
    end
  end

  private

  # TODO factorize that with Instance
  def replace_vars(string, vars)
    new_string = string.dup
    var_names = new_string.scan(/\$(\S+)/).flatten
    unless var_names.empty?
      var_names.each do |var_name|
        new_string.gsub!("$#{var_name}", vars[var_name])
      end
    end
    new_string
  end
end
