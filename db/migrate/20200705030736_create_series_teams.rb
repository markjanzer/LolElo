# frozen_string_literal: true

class CreateSeriesTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :series_teams do |t|
      t.belongs_to :serie
      t.belongs_to :team
    end
  end
end
