class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.string :type
      t.text :details

      t.timestamps
    end
  end
end
