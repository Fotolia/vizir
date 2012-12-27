class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.integer :entity_id
      t.integer :metric_id
      t.integer :provider_id
      t.text :details

      t.timestamps
    end
  end
end
