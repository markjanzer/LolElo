# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Updater do
  describe "#call" do
    it "creates new series for a league" do
      league_id = 1
      serie_id = 2
      tournament_id = 3
      team_ids = [4, 5]
      match_id = 6
      game_id = 7
      
      create(:panda_score_league, id: 1)
      league_data = {
        "id" => league_id
      }
      allow(PandaScoreAPI).to receive(:league).with(id: league_id).and_return(league_data)

      serie_data = {
        "id" => serie_id,
        "end_at" => 1.day.from_now.iso8601,
        "tournaments" => [{ 
          "id" => tournament_id,
        }]
      }
      allow(PandaScoreAPI).to receive(:series).with(league_id: league_id).and_return([serie_data])
      allow(PandaScoreAPI).to receive(:serie).with(id: 2).and_return(serie_data)

      teams_data = [
        { "id" => team_ids[0] },
        { "id" => team_ids[1] }
      ]
      tournament_data = {
        "id" => tournament_id,
        "end_at" => 1.day.from_now.iso8601,
        "teams" => teams_data
      }
      allow(PandaScoreAPI).to receive(:tournaments).with(serie_id: serie_id).and_return([tournament_data])
      allow(PandaScoreAPI).to receive(:tournament).with(id: tournament_id).and_return(tournament_data)
      allow(PandaScoreAPI).to receive(:team).with(id: team_ids[0]).and_return(teams_data[0])
      allow(PandaScoreAPI).to receive(:team).with(id: team_ids[1]).and_return(teams_data[1])

      match_data = { 
        "id" => match_id,
        "end_at" => nil,
        "status" => "running",
        "games" => [
          { "id" => game_id } 
        ]
      }
      allow(PandaScoreAPI).to receive(:matches).with(tournament_id: tournament_id).and_return([match_data])
      allow(PandaScoreAPI).to receive(:match).with(id: match_id).and_return(match_data)
      
      expect(PandaScore::Serie.count).to eq(0)
      expect(PandaScore::Tournament.count).to eq(0)
      expect(PandaScore::Team.count).to eq(0)
      expect(PandaScore::Match.count).to eq(0)
      expect(PandaScore::Game.count).to eq(0)
      expect(UpdateTracker.count).to eq(0)

      Updater.new.call

      expect(PandaScore::League.first.data).to eq(league_data)
      expect(PandaScore::Serie.count).to eq(1)
      expect(PandaScore::Serie.first.data).to eq(serie_data)
      expect(PandaScore::Tournament.count).to eq(1)
      expect(PandaScore::Tournament.first.data).to eq(tournament_data)
      expect(PandaScore::Team.count).to eq(2)
      expect(PandaScore::Match.count).to eq(1)
      expect(PandaScore::Match.first.data).to eq(match_data)
      expect(PandaScore::Game.count).to eq(1)
      expect(UpdateTracker.count).to eq(1)
    end
  end
end