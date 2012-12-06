class Metric < ActiveRecord::Base
  attr_accessible :details, :name, :provider_id, :type, :unit
end
