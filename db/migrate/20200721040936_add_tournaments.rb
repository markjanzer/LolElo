# frozen_string_literal: true

class AddTournaments < ActiveRecord::Migration[6.0]
  def change
    create_table :tournaments do |t|
      t.integer :external_id
      t.string :name
      t.references :serie
    end

    drop_table :series_teams

    create_table :teams_tournaments do |t|
      t.belongs_to :team
      t.belongs_to :tournament
    end

    remove_reference :matches, :serie, index: true
    add_reference :matches, :tournament, index: true
  end
end
