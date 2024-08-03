class AddModelUpdateCompletedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :update_trackers, :model_update_completed_at, :datetime
  end
end
