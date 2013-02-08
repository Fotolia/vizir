class AddUniqueNameToGraphs < ActiveRecord::Migration
  def change
    add_column :graphs, :unique_name, :string
  end
end
