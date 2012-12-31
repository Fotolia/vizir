class Instance < ActiveRecord::Base
  attr_accessible :entity_id, :metric_id, :provider_id, :details

  serialize :details, JSON

  validates :entity_id, :provider_id, :metric_id,
    :presence => true

  belongs_to :entity
  belongs_to :metric
  belongs_to :provider

  scope :w_assocs, includes(:metric, :entity)

  def fetch_values(start, finish)
    options = get_details
    options["entity"] = entity.name
    options["start"] = start
    options["end"] = finish

    data = {
      "name" => title,
      "data" => provider.get_values(options)
    }
  end

  def get_details
    details.nil? ? metric.details : metric.details.merge(details)
  end

  def title
    if metric.title
      replace_vars(metric.title.dup, details)
    else
      metric.name
    end
  end

  private

  def replace_vars(string, vars)
    var_names = string.scan(/\$(\S+)/).flatten
    unless var_names.empty?
      var_names.each do |var_name|
        string.gsub!("$#{var_name}", vars[var_name])
      end
    end
    string
  end
end
