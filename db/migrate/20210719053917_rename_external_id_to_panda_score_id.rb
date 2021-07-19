class RenameExternalIdToPandaScoreId < ActiveRecord::Migration[6.0]
  def change
    rename_column :leagues, :external_id, :panda_score_id
    rename_column :series, :external_id, :panda_score_id
    rename_column :tournaments, :external_id, :panda_score_id
    rename_column :teams, :external_id, :panda_score_id
    rename_column :matches, :external_id, :panda_score_id
    rename_column :games, :external_id, :panda_score_id
  end
end
