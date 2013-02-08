class GraphsInstance < ActiveRecord::Base
  attr_accessible :sort, :instance_id, :graph_id

  validates :instance_id,
    :uniqueness => { :scope => :graph_id }

  belongs_to :graph
  belongs_to :instance
end
