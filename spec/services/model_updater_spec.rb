# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelUpdater do
  describe "#call" do
    it "creates all of the models from the updated PandaScore objects" do
      create(:update_tracker, completed_at: 2.days.ago)
      create(:update_tracker, completed_at: 1.hour.ago)

      league_id, serie_id, tournament_id, match_id, team1_id, team2_id = 1, 2, 3, 4, 5, 6

      league = create(:league, panda_score_id: league_id)
      
      create(:panda_score_serie, updated_at: 1.day.ago, panda_score_id: serie_id, data: {
        league_id: league_id,
        year: 2020,
        begin_at: "2020-01-01",
        full_name: "Spring Split",
      })
      create(:panda_score_tournament, updated_at: 1.day.ago, panda_score_id: tournament_id, data: {
        serie_id: serie_id,
        name: "Tournament",
        teams: [
          { id: team1_id },
          { id: team2_id }
        ]
      })
      create(:panda_score_team, panda_score_id: team1_id, data: {
        acronym: "C9"
      })
      create(:panda_score_team, panda_score_id: team2_id, data: {
        acronym: "T1"
      })
      create(:panda_score_match, updated_at: 1.day.ago, panda_score_id: match_id, data: {
        tournament_id: tournament_id,
        end_at: "2020-01-01",
        opponents: [
          { opponent: { id: team1_id } },
          { opponent: { id: team2_id } }
        ]
      })
      create(:panda_score_game, updated_at: 1.day.ago, data: {
        match_id: match_id,
        end_at: "2020-01-01",
        winner: { id: team1_id }
      })

      expect(Serie.count).to eq(0)
      expect(Tournament.count).to eq(0)
      expect(Team.count).to eq(0)
      expect(TeamsTournament.count).to eq(0)
      expect(Match.count).to eq(0)
      expect(Game.count).to eq(0)

      ModelUpdater.call

      expect(Serie.count).to eq(1)
      serie = Serie.first
      expect(serie.year).to eq(2020)
      expect(serie.league).to eq(league)
      expect(serie.begin_at).to eq("2020-01-01")
      expect(serie.full_name).to eq("Spring Split")

      expect(Tournament.count).to eq(1)
      tournament = Tournament.first
      expect(tournament.name).to eq("Tournament")
      expect(tournament.serie).to eq(serie)
      
      expect(Team.count).to eq(2)
      team1 = Team.find_by(panda_score_id: team1_id)
      team2 = Team.find_by(panda_score_id: team2_id)
      expect(TeamsTournament.count).to eq(2)

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
      create(:update_tracker, update_type: :model, completed_at: 2.days.ago)

      league_id = 1
      create(:league, panda_score_id: league_id)
      create(:panda_score_serie, updated_at: 3.days.ago, data: {
        full_name: "Spring Split",
        league_id: league_id
      })

      expect(Serie.count).to eq(0)
      ModelUpdater.call
      expect(Serie.count).to eq(0)
    end

    it "creates a new UpdateTracker record" do
      expect { ModelUpdater.call }.to change { UpdateTracker.count }.by(1)
      expect(UpdateTracker.last.update_type).to eq("model")
    end
  end
end