class CreateGame < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.references :match
      t.references :winner
      t.integer :external_id
      t.datetime :end_at

      t.index :external_id
    end
  end
end
