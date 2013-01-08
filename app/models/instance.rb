class Instance < ActiveRecord::Base
  attr_accessible :entity_id, :metric_id, :provider_id, :details

  serialize :details, JSON

  validates :entity_id, :provider_id, :metric_id,
    :presence => true

  belongs_to :entity
  belongs_to :metric
  belongs_to :provider

  has_and_belongs_to_many :graphs

  scope :incl_assocs, includes(:metric, :entity, :provider)
  scope :join_assocs, joins(:metric, :entity, :provider)
  scope :wo_graph, includes(:graphs).where(:graphs => {:id => nil})

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
      replace_vars(metric.title, details)
    else
      metric.name
    end
  end

  private

  # TODO factorize that with Graph
  def replace_vars(string, vars)
    new_string = string.dup
    var_names = new_string.scan(/\$(\S+)/).flatten
    unless var_names.empty?
      var_names.each do |var_name|
        new_string.gsub!("$#{var_name}", vars[var_name])
      end
    end
    new_string
  end
end
