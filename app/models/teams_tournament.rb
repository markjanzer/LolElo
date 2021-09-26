# frozen_string_literal: true

class TeamsTournament < ApplicationRecord
  belongs_to :tournament
  belongs_to :team

  validates_uniqueness_of :team_id, scope: :tournament_id
end