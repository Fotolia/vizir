class Instance < ActiveRecord::Base
  attr_accessible :entity_id, :metric_id, :provider_id, :details

  serialize :details, JSON

  belongs_to :entity
  belongs_to :metric
  belongs_to :provider

  scope :w_assocs, includes(:metric, :entity)

  def fetch_values(start, finish)
    metric.fetch_values(start, finish, entity, provider)
  end
end
