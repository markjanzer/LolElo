# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_24_010833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.bigint "match_id"
    t.bigint "winner_id"
    t.integer "external_id"
    t.datetime "started_at"
    t.index ["external_id"], name: "index_games_on_external_id"
    t.index ["match_id"], name: "index_games_on_match_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "date"
    t.bigint "opponent_1_id"
    t.bigint "opponent_2_id"
    t.integer "external_id"
    t.index ["opponent_1_id"], name: "index_matches_on_opponent_1_id"
    t.index ["opponent_2_id"], name: "index_matches_on_opponent_2_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "acronym"
    t.integer "external_id"
    t.string "color"
    t.index ["external_id"], name: "index_teams_on_external_id"
  end

end
