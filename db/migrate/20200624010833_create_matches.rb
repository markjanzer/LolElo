class CreateMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :matches do |t|
      t.datetime :end_at
      t.references :opponent_1
      t.references :opponent_2
      t.integer :external_id
    end
  end
end
