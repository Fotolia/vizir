class CreateGraphsInstances < ActiveRecord::Migration
  def change
    create_table :graphs_instances do |t|
      t.integer :graph_id
      t.integer :instance_id
    end
  end
end
