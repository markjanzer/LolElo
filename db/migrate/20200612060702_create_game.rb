class CreateGame < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.datetime :date
      t.references :opponent_1
      t.references :opponent_2
      t.references :winner
      t.integer :external_id

      t.index(:external_id)
    end
  end
end
