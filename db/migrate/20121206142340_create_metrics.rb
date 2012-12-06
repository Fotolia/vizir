class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name
      t.string :type
      t.string :unit
      t.text :details
      t.integer :provider_id

      t.timestamps
    end
  end
end
