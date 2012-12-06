class Provider < ActiveRecord::Base
  attr_accessible :name, :type, :details

  serialize :details, JSON

  has_many :metrics

  def get_entities
    raise "Method not implemented"
  end

  def get_metrics
    raise "Method not implemented"
  end

  def get_data(options = {})
    raise "Method not implemented"
  end

  def load_definitions
    raise "Method not implemented"
  end
end
