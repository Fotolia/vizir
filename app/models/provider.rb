class Provider < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :type, :details

  serialize :details, JSON

  validates :name,
    :uniqueness => true,
    :presence => true
  validates :type,
    :presence => true

  has_many :instances

  def load_metrics
    existing_entities = Entity.all
    puts "Entities:"
    p existing_entities
    puts
    existing_metrics = Metric.all
    puts "Metrics:"
    p existing_metrics
    puts
    Instance.destroy_all
    #ActiveRecord::Base.connection.reset_pk_sequence!(Instance.table_name)
    unless @data.nil?
      new_metrics = []
      @data.each do |entity_name, metrics|
        # first, entity
        entities = existing_entities.select {|e| e.name == entity_name}
        if entities.empty?
          entity = Entity.create(:name => entity_name)
        else
          entity = existing_entities.delete(entities.first)
        end

        # then metrics
        metrics.each do |metric_h|
          metric = metric_type.new(metric_h)

          instance = Instance.new
          instance.assign_attributes({:entity => entity, :provider => self }, :without_protection => true)
          instance.details = metric.instance_details unless metric.instance_details.nil?

          metrics = existing_metrics.select {|m| m.name == metric.name}
          if metrics.empty?
            metrics = new_metrics.select {|m| m.name == metric.name}
            if metrics.empty?
              new_metrics << metric
              metric.save!
            else
              metric = metrics.first
            end
          else
            existing_metric = existing_metrics.delete(metrics.first)
            existing_metric.update_attributes(metric.attributes.select {|a| [:id, :created_at, :updated_at].include?(a)})
            if existing_metric.changed?
              existing_metric.save!
            end
            metric = existing_metric
            new_metrics << metric
          end

          instance.metric = metric
          instance.save!
        end
      end
    end
    existing_entities.each {|e| Entity.find_by_name(e).destroy}
    existing_metrics.each {|m| Metric.find_by_name(m).destroy}
  end

  def get_values(options = {})
    raise "Method not implemented"
  end

  def metric_type
    self.class.to_s.gsub('Provider', 'Metric').constantize
  end
end
