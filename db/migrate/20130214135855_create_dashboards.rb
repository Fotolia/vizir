class CreateDashboards < ActiveRecord::Migration
  def change
    create_table :dashboards do |t|
      t.string :name
      t.text :options
      t.integer :entity_id
    end
  end
end
