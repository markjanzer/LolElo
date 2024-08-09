class AddForeignKeys < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :series, :leagues, column: :league_id, on_delete: :cascade
    add_foreign_key :tournaments, :series, column: :serie_id, on_delete: :cascade
    add_foreign_key :matches, :tournaments, column: :tournament_id, on_delete: :cascade
    add_foreign_key :games, :matches, column: :match_id, on_delete: :cascade
    add_foreign_key :snapshots, :teams, column: :team_id, on_delete: :cascade
    add_foreign_key :teams_tournaments, :teams, column: :team_id, on_delete: :cascade
    add_foreign_key :teams_tournaments, :tournaments, column: :tournament_id, on_delete: :cascade
  end
end
