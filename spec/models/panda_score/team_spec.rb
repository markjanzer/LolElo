# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::Team do
  describe "#tournament" do
    it "returns the tournament from the data" do
      tournament = create(:tournament)
      panda_score_team = create(:panda_score_team, data: { "tournament_id" => tournament.panda_score_id })

      expect(panda_score_team.tournament).to eq(tournament)
    end
  end
end