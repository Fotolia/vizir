class GraphsInstance < ActiveRecord::Base
  attr_accessible :sort, :instance

  belongs_to :graph
  belongs_to :instance
end
