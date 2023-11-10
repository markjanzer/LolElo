# frozen_string_literal: true

class PandaScore::Tournament < ApplicationRecord
  self.table_name = 'panda_score_tournaments'

  def serie
    Serie.find_by(panda_score_id: data['serie_id'])
  end
end
