# frozen_string_literal: true

class CreateSnapshots < ActiveRecord::Migration[6.0]
  def change
    create_table :snapshots do |t|
      t.references :team
      t.references :game
      t.datetime :datetime
      t.integer :elo
    end
  end
end
