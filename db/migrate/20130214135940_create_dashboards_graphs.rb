class CreateDashboardsGraphs < ActiveRecord::Migration
  def change
    create_table :dashboards_graphs do |t|
      t.integer :dashboard_id
      t.integer :graph_id
    end
  end
end
