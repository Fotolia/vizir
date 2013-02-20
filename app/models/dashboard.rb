class Dashboard < ActiveRecord::Base
  attr_accessible :entity_id, :name, :options
  attr_accessor :title, :scope

  validates :name,
    :presence => true

  belongs_to :entity, :inverse_of => :dashboards
  has_and_belongs_to_many :graphs, :uniq => true

  after_find do |dashboard|
    dashboard.dsl_override
  end

  def self.load_defs
    Vizir::DSL.dashboards.each do |dashboard_def|
      name, scope = dashboard_def[:name], dashboard_def[:scope]
      graph_list = dashboard_def[:graphs].keys

      case scope
      when nil
        Entity.includes(:graphs).each do |entity|
          dashboard = where(:name => name, :entity_id => entity.id).first_or_initialize
          dashboard.graphs = entity.graphs.uniq.select{|graph| graph_list.include?(graph.name)}
          dashboard.save!
        end
      end
    end
  end

  def title
    @title ? @title : name
  end

  protected

  def dsl_override
    dashboard_def = Vizir::DSL.dashboards.select {|d| d[:name] == self.name}
    unless dashboard_def.empty?
      dashboard_def.first.each do |key, value|
        if self.respond_to?(key) and key != :graphs
          val = value.is_a?(String) ? value.dup : value
          self.send("#{key}=", val)
        end
      end
    end
  end
end
