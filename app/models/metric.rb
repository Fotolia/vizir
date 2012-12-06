class Metric < ActiveRecord::Base
  attr_accessible :name, :type, :unit, :details, :provider_id

  serialize :details, JSON

  has_many :entity_metrics
  has_many :entities, :through => :entity_metrics

  belongs_to :provider

  def fetch_values(start, finish, entity)
    options = details
    options["entity"] = entity
    options["start"] = start
    options["end"] = finish
    provider.get_data(options)
  end
end
