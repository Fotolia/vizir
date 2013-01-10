class Provider < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :type, :details

  serialize :details, JSON

  validates :name,
    :uniqueness => true,
    :presence => true
  validates :type,
    :presence => true

  has_many :instances, :inverse_of => :provider

  def load_metrics(data)
    Instance.destroy_all
    Instance.reset_pk_sequence
    new_entities = []
    new_metrics = []

    data.each do |entity_name, metrics|
      # first, entity
      # retrieve DB row if any, or create one
      entity = Entity.find_or_create_by_name(entity_name)

      # then metrics and instances
      metrics.each do |metric_h|
        m = metric_type.new(metric_h)

        instance = Instance.new
        instance.assign_attributes({:entity => entity, :provider => self }, :without_protection => true)
        instance.details = m.instance_details unless m.instance_details.nil?

        # retrieve DB row if any, or create one
        if metric = metric_type.find_by_name(m.name)
          metric.update_attributes!(:details => m.details)
        else
          metric = m
          metric.save!
        end
        new_metrics << metric.id

        instance.metric = metric
        instance.save!
      end
    end

    Entity.where("id NOT IN (?)", new_entities).destroy_all
    Metric.where("id NOT IN (?)", new_metrics).destroy_all
  end

  def get_values(options = {})
    raise "Method not implemented"
  end

  def metric_type
    self.class.to_s.gsub('Provider', 'Metric').constantize
  end
end
