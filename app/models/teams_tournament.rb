# frozen_string_literal: true

class TeamsTournament < ApplicationRecord
  belongs_to :tournament
  belongs_to :team
end