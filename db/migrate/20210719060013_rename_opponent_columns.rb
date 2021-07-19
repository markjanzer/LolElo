class RenameOpponentColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :matches, :opponent_1_id, :opponent1_id
    rename_column :matches, :opponent_2_id, :opponent2_id
  end
end
