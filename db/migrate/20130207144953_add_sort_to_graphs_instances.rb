class AddSortToGraphsInstances < ActiveRecord::Migration
  def change
    add_column :graphs_instances, :sort, :integer
  end
end
