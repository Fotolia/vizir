class RemoveAllTimestamps < ActiveRecord::Migration
  def change
    remove_timestamps :providers
    remove_timestamps :entities
    remove_timestamps :metrics
    remove_timestamps :instances
    remove_timestamps :graphs
  end
end
