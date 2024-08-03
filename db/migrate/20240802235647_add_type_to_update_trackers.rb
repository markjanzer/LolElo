class AddTypeToUpdateTrackers < ActiveRecord::Migration[7.0]
  def change
    add_column :update_trackers, :update_type, :string, null: false, default: "api"
    add_index :update_trackers, :update_type
  end
end
