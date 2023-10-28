class CreatePandaScoreLeagues < ActiveRecord::Migration[7.0]
  def change
    create_table :panda_score_leagues do |t|
      t.integer :panda_score_id, null: false, index: { unique: true }
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
