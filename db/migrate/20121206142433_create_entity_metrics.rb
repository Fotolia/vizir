class CreateEntityMetrics < ActiveRecord::Migration
  def change
    create_table :entity_metrics do |t|
      t.integer :entity_id
      t.integer :metric_id
      t.string :instance

      t.timestamps
    end
  end
end
