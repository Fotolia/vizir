class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name
      t.string :type
      t.text :details

      t.timestamps
    end
  end
end
