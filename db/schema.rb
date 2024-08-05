# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_08_02_235647) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.bigint "match_id"
    t.bigint "winner_id"
    t.integer "panda_score_id"
    t.datetime "end_at", precision: nil
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["match_id"], name: "index_games_on_match_id"
    t.index ["panda_score_id"], name: "index_games_on_panda_score_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name"
    t.integer "panda_score_id"
    t.string "time_zone"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["panda_score_id"], name: "index_leagues_on_panda_score_id"
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "end_at", precision: nil
    t.bigint "opponent1_id"
    t.bigint "opponent2_id"
    t.integer "panda_score_id"
    t.bigint "tournament_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["opponent1_id"], name: "index_matches_on_opponent1_id"
    t.index ["opponent2_id"], name: "index_matches_on_opponent2_id"
    t.index ["tournament_id"], name: "index_matches_on_tournament_id"
  end

  create_table "panda_score_games", force: :cascade do |t|
    t.integer "panda_score_id", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["panda_score_id"], name: "index_panda_score_games_on_panda_score_id", unique: true
  end

  create_table "panda_score_leagues", force: :cascade do |t|
    t.integer "panda_score_id", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["panda_score_id"], name: "index_panda_score_leagues_on_panda_score_id", unique: true
  end

  create_table "panda_score_matches", force: :cascade do |t|
    t.integer "panda_score_id", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["panda_score_id"], name: "index_panda_score_matches_on_panda_score_id", unique: true
  end

  create_table "panda_score_series", force: :cascade do |t|
    t.integer "panda_score_id", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["panda_score_id"], name: "index_panda_score_series_on_panda_score_id", unique: true
  end

  create_table "panda_score_teams", force: :cascade do |t|
    t.integer "panda_score_id", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["panda_score_id"], name: "index_panda_score_teams_on_panda_score_id", unique: true
  end

  create_table "panda_score_tournaments", force: :cascade do |t|
    t.integer "panda_score_id", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["panda_score_id"], name: "index_panda_score_tournaments_on_panda_score_id", unique: true
  end

  create_table "series", force: :cascade do |t|
    t.integer "panda_score_id"
    t.datetime "begin_at", precision: nil
    t.string "full_name"
    t.integer "year"
    t.bigint "league_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["league_id"], name: "index_series_on_league_id"
  end

  create_table "snapshots", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "game_id"
    t.datetime "datetime", precision: nil
    t.integer "elo"
    t.bigint "serie_id"
    t.boolean "elo_reset", default: false, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["game_id"], name: "index_snapshots_on_game_id"
    t.index ["serie_id"], name: "index_snapshots_on_serie_id"
    t.index ["team_id"], name: "index_snapshots_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "acronym"
    t.integer "panda_score_id"
    t.string "color"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["panda_score_id"], name: "index_teams_on_panda_score_id"
  end

  create_table "teams_tournaments", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "tournament_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["team_id", "tournament_id"], name: "index_teams_tournaments_on_team_id_and_tournament_id", unique: true
    t.index ["tournament_id"], name: "index_teams_tournaments_on_tournament_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.integer "panda_score_id"
    t.string "name"
    t.bigint "serie_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["serie_id"], name: "index_tournaments_on_serie_id"
  end

  create_table "update_trackers", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "update_type", default: "api", null: false
    t.datetime "model_update_completed_at"
    t.index ["update_type"], name: "index_update_trackers_on_update_type"
  end

  add_foreign_key "snapshots", "series", column: "serie_id"
end
