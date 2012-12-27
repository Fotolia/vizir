class Metric < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :type, :details

  serialize :details, JSON

  validates :name,
    :uniqueness => true,
    :presence => true

  has_many :instances
  has_many :entities, :through => :instances

  def fetch_values(start, finish, entity, provider)
    options = details
    options["entity"] = entity.name
    options["start"] = start
    options["end"] = finish

    data = {
      "name" => name,
      "data" => provider.get_values(options)
    }
  end

  def ==(metric)
    self.name == metric.name and self.details == metric.details
  end

#  before_create do |metric|
#    metric_def = []
#    if metric_defs = Vizir::DSL[:metric][metric.type]
#      metric_def = metric_defs.select {|m| m[:rrd].match(metric.rrd) and m[:ds] == metric.ds}
#    end
#    unless metric_def.empty?
#      metric.name = metric_def.first[:name]
#    end
#  end
end
