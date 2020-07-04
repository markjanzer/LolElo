class CreateLeagues < ActiveRecord::Migration[6.0]
  def change
    create_table :leagues do |t|
      t.string :name
      t.integer :external_id

      t.index :external_id
    end

    add_reference :series, :league, index: true
  end
end
