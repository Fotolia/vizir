require 'sti_helpers'

class Metric < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :title, :type, :unit, :details, :provider_id

  serialize :details, JSON

  has_many :entity_metrics
  has_many :entities, :through => :entity_metrics

  belongs_to :provider

  def fetch_values(start, finish, entity)
    options = details
    options["entity"] = entity
    options["start"] = start
    options["end"] = finish

    data = {
      "name" => name,
      "data" => provider.get_values(options)
    }
  end
end
