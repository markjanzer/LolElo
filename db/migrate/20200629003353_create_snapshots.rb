class CreateSnapshots < ActiveRecord::Migration[6.0]
  def change
    create_table :snapshots do |t|
      t.references :team
      t.references :game
      t.datetime :date
      t.integer :elo
    end
  end
end
