class RemoveCapacityFromEvents < ActiveRecord::Migration[8.1]
  def change
    remove_column :events, :capacity, :integer
  end
end
