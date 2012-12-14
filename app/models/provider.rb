require 'sti_helpers'

class Provider < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :type, :details

  serialize :details, JSON

  validates :name,
    :uniqueness => true,
    :presence => true
  validates :type,
    :presence => true

  has_many :metrics

  def get_entities
    raise "Method not implemented"
  end

  def get_metrics
    raise "Method not implemented"
  end

  def get_values(options = {})
    raise "Method not implemented"
  end

  def load_definitions
    raise "Method not implemented"
  end
end
