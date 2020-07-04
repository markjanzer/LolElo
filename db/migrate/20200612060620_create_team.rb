class CreateTeam < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :acronym
      t.integer :external_id
      t.string :color
      
      t.index :external_id
    end
  end
end
