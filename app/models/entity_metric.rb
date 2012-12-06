class EntityMetric < ActiveRecord::Base
  attr_accessible :entity_id, :metric_id, :instance

  belongs_to :entity
  belongs_to :metric

  def fetch_values(start, finish)
    metric.fetch_values(start, finish, entity.name)
  end
end
