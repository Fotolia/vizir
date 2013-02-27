class Provider < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :type, :details
  attr_custom :ignore_unknown_metrics

  serialize :details, JSON

  validates :name,
    :uniqueness => true,
    :presence => true
  validates :type,
    :presence => true

  has_many :instances, :inverse_of => :provider

  def load_metrics(data, ignore_unknown_metrics = false)
    new_entities = []
    new_metrics = []

    ActiveRecord::Base.transaction do
      data.each do |entity_name, metrics|
        # first, entity
        # retrieve DB row if any, or create one
        entity = Entity.find_or_create_by_name(entity_name)
        new_entities << entity.id

        instances = Instance.where(:entity_id => entity.id).inject({}){|h,i| (h[i.metric_id] ||= []) << i.unique_name; h}

        # then metrics and instances
        metrics.each do |metric_h|
          metric_found, instance_found = false, false

          m = metric_type.new(metric_h)

          # skip creation if metric not defined in DSL and ignore_unknown_metrics option set on provider
          next if !m.defined and ignore_unknown_metrics

          # retrieve DB row if any, or create one
          if metric = metric_type.find_by_name(m.name)
            metric_found = true
            if instances.has_key?(metric.id) and instances[metric.id].include?(m.instance_details.values.sort.join("|"))
              instance_found = true
            end
          end

          unless instance_found
            unless metric_found
              metric = m
              metric.save!
            end
            Instance.create(:entity_id => entity.id, :metric_id => metric.id, :provider_id => self.id, :details => m.details.merge(m.instance_details))
          end
          new_metrics << metric.id
        end
      end

      Entity.where("id NOT IN (?)", new_entities).destroy_all
      Metric.where("id NOT IN (?)", new_metrics).destroy_all
    end
  end

  def get_values(options = {})
    raise "Method not implemented"
  end

  def metric_type
    self.class.to_s.gsub('Provider', 'Metric').constantize
  end
end
