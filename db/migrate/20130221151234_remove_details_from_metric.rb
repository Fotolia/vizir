class RemoveDetailsFromMetric < ActiveRecord::Migration
  def up
    remove_column :metrics, :details
  end

  def down
    add_column :metrics, :details, :text
  end
end
