# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelUpdater do
  describe "#call" do
    it "creates all of the models from the updated PandaScore objects" do
      create(:update_tracker, completed_at: 2.days.ago)
      create(:update_tracker, completed_at: 1.hour.ago)

      league_id, serie_id, tournament_id, match_id = 1, 2, 3, 4
      team1, team2 = create(:team), create(:team)

      league = create(:league, panda_score_id: league_id)
      
      create(:panda_score_serie, updated_at: 1.day.ago, panda_score_id: serie_id, data: {
        league_id: league_id,
        year: 2020,
        begin_at: "2020-01-01",
        full_name: "2020 Season",
      })
      create(:panda_score_tournament, updated_at: 1.day.ago, panda_score_id: tournament_id, data: {
        serie_id: serie_id,
        name: "Tournament",
      })
      create(:panda_score_match, updated_at: 1.day.ago, panda_score_id: match_id, data: {
        tournament_id: tournament_id,
        end_at: "2020-01-01",
        opponents: [
          { opponent: { id: team1.panda_score_id } },
          { opponent: { id: team2.panda_score_id } }
        ]
      })
      create(:panda_score_game, updated_at: 1.day.ago, data: {
        match_id: match_id,
        end_at: "2020-01-01",
        winner: { id: team1.panda_score_id }
      })

      expect(Serie.count).to eq(0)
      expect(Tournament.count).to eq(0)
      expect(Match.count).to eq(0)
      expect(Game.count).to eq(0)

      ModelUpdater.call

      expect(Serie.count).to eq(1)
      serie = Serie.first
      expect(serie.year).to eq(2020)
      expect(serie.league).to eq(league)
      expect(serie.begin_at).to eq("2020-01-01")
      expect(serie.full_name).to eq("2020 Season")

      expect(Tournament.count).to eq(1)
      tournament = Tournament.first
      expect(tournament.name).to eq("Tournament")
      expect(tournament.serie).to eq(serie)

      expect(Match.count).to eq(1)
      match = Match.first
      expect(match.tournament).to eq(tournament)
      expect(match.end_at).to eq("2020-01-01")
      expect(match.opponent1).to eq(team1)
      expect(match.opponent2).to eq(team2)

      expect(Game.count).to eq(1)
      game = Game.first
      expect(game.match).to eq(match)
      expect(game.end_at).to eq("2020-01-01")
      expect(game.winner).to eq(team1)
    end

    it "does not update models that have not been updated since the last run" do
      create(:update_tracker, completed_at: 2.days.ago)
      create(:update_tracker, completed_at: 1.hour.ago)

      league_id = 1
      create(:league, panda_score_id: league_id)
      create(:panda_score_serie, updated_at: 3.days.ago, data: {
        league_id: league_id
      })

      expect(Serie.count).to eq(0)
      ModelUpdater.call
      expect(Serie.count).to eq(0)
    end
  end
end