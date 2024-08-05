# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PandaScore::Game do
  describe "#match" do
    it "returns the match from the data" do
      match = create(:match)
      panda_score_game = create(:panda_score_game, data: { "match_id" => match.panda_score_id })

      expect(panda_score_game.match).to eq(match)
    end
  end

  describe "#winner" do
    it "returns the winner from the data" do
      team = create(:team)
      panda_score_game = create(:panda_score_game, data: { "winner" => { "id" => team.panda_score_id } })

      expect(panda_score_game.winner).to eq(team)
    end
  end
end