class CreateGame < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.referneces :match
      t.references :winner
      t.integer :external_id
    end
  end
end
