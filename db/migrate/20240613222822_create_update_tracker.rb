class CreateUpdateTracker < ActiveRecord::Migration[7.0]
  def change
    create_table :update_trackers do |t|
      t.datetime :completed_at
      t.timestamps
    end
  end
end
