# frozen_string_literal: true

class PandaScore::Serie < ApplicationRecord
  self.table_name = 'panda_score_series'
  
  def create_or_update_serie
    new_serie = Serie.find_or_initialize_by(panda_score_id: panda_score_id)
    new_serie.assign_attributes({
      year: data["year"],
      begin_at: data["begin_at"],
      full_name: data["full_name"],
    })
    league.series << new_serie
  end

  private

  def league
    puts data["league_id"]
    League.find_by(panda_score_id: data["league_id"])
  end
end
