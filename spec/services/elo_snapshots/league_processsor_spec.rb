# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EloSnapshots::LeagueProcessor do
  describe "#call" do
    let(:new_team_elo) { EloCalculator::NEW_TEAM_ELO }

    context "if the league is not defined" do
      it "raises an error" do
        expect { described_class.call(nil) }.to raise_error "league not defined"
      end
    end

    context "when the league does not have any series" do
      it "doesn't create any snapshots" do
        league = create(:league)
        expect { described_class.call(league) }.not_to change { Snapshot.count }
      end
    end

    def create_match
      league = create(:league)
      serie = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)
      tournament = create(:tournament, serie: serie)
      team1, team2 = create_list(:team, 2)
      match1 = create(:match, opponent1: team1, opponent2: team2, tournament: tournament)

      { league: league, serie: serie, tournament: tournament, team1: team1, team2: team2, match1: match1 }
    end

    context "when there are two games without snapshots" do
      it "calculates the games in the correct order" do
        league, team1, team2, match1 = create_match.values_at(:league, :team1, :team2, :match1)
        _game1 = create(:game, match: match1, winner: team1, end_at: "2020-01-02")
        _game2 = create(:game, match: match1, winner: team2, end_at: Date.parse("2020-01-02") + 1.hour)

        team1_elo, team2_elo = [new_team_elo, new_team_elo]
        team1_elo1, team2_elo1 = EloCalculator::GameResults.new(winner_elo: team1_elo, loser_elo: team2_elo).new_elos
        # Swap assignment because the winner is the first elo returned
        team2_elo2, team1_elo2 = EloCalculator::GameResults.new(winner_elo: team2_elo1, loser_elo: team1_elo1).new_elos

        described_class.call(league)

        expect(team1.elo).to eq team1_elo2
        expect(team2.elo).to eq team2_elo2
      end
    end

    context "when there is a gap in snapshots of consecutive games" do
      def create_games_with_snapshot_gap
        league = create(:league)
        serie = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)
        tournament = create(:tournament, serie: serie)
        team1, team2 = create_list(:team, 2)
        match1 = create(:match, opponent1: team1, opponent2: team2, tournament: tournament)
        game1 = create(:game, match: match1, winner: team1, end_at: "2020-01-02")
        game2 = create(:game, match: match1, winner: team2, end_at: Date.parse("2020-01-02") + 1.hour)
        game3 = create(:game, match: match1, winner: team2, end_at: Date.parse("2020-01-02") + 2.hours)
        game1_team1_snapshot = create(:snapshot, game: game1, team: team1, elo: 2550, datetime: game1.end_at, serie: serie)
        game1_team2_snapshot = create(:snapshot, game: game1, team: team2, elo: 2450, datetime: game1.end_at, serie: serie)
        game3_team1_snapshot = create(:snapshot, game: game3, team: team1, elo: 2600, datetime: game3.end_at, serie: serie)
        game3_team2_snapshot = create(:snapshot, game: game3, team: team2, elo: 2400, datetime: game3.end_at, serie: serie)

        { league: league, game2: game2, game3: game3, game1_team1_snapshot: game1_team1_snapshot, game1_team2_snapshot: game1_team2_snapshot, game3_team1_snapshot: game3_team1_snapshot, game3_team2_snapshot: game3_team2_snapshot }
      end

      it "creates snapshots for games without snapshots" do
        league, game2 = create_games_with_snapshot_gap.values_at(:league, :game2)

        expect { described_class.call(league) }.to change { Snapshot.count }.by(2)
        expect(game2.snapshots.count).to eq 2
      end

      it "replaces the snapshots after the gap" do
        league, game3, game3_team1_snapshot, game3_team2_snapshot = create_games_with_snapshot_gap.values_at(:league, :game3, :game3_team1_snapshot, :game3_team2_snapshot)

        expect { described_class.call(league) }.not_to change { game3.snapshots.count }
        expect(Snapshot.find_by(id: game3_team1_snapshot.id)).to be_nil
        expect(Snapshot.find_by(id: game3_team2_snapshot.id)).to be_nil
      end

      it "doesn't change snapshots before the gap" do
        league, game1_team1_snapshot, game1_team2_snapshot = create_games_with_snapshot_gap.values_at(:league, :game1_team1_snapshot, :game1_team2_snapshot)

        described_class.call(league)
        expect(Snapshot.where(id: game1_team1_snapshot.id)).to be_present
        expect(Snapshot.where(id: game1_team2_snapshot.id)).to be_present
      end
    end

    context "when passed a datetime" do
      it "recalculates elos of games from that time forward" do
        league, serie, team1, team2, match1 = create_match.values_at(:league, :serie, :team1, :team2, :match1)
        game1_time, game2_time, game3_time = [Date.parse("2020-01-02") + 1.hour, Date.parse("2020-01-02") + 2.hours, Date.parse("2020-01-02") + 3.hours]
        game1 = create(:game, match: match1, winner: team1, end_at: game1_time)
        game2 = create(:game, match: match1, winner: team2, end_at: game2_time)
        game3 = create(:game, match: match1, winner: team2, end_at: game3_time)
        _game1_team1_snapshot = create(:snapshot, game: game1, datetime: game1_time, team: team1, serie: serie)
        _game1_team2_snapshot = create(:snapshot, game: game1, datetime: game1_time, team: team2, serie: serie)
        game2_team1_snapshot = create(:snapshot, game: game2, datetime: game2_time, team: team1, serie: serie)
        game2_team2_snapshot = create(:snapshot, game: game2, datetime: game2_time, team: team2, serie: serie)
        game3_team1_snapshot = create(:snapshot, game: game3, datetime: game3_time, team: team1, serie: serie)
        game3_team2_snapshot = create(:snapshot, game: game3, datetime: game3_time, team: team2, serie: serie)
        
        expect { described_class.new(league, game2_time).call }.not_to change { Snapshot.count }

        expect(Snapshot.find_by(id: game2_team1_snapshot.id)).to be_nil
        expect(Snapshot.find_by(id: game2_team2_snapshot.id)).to be_nil
        expect(Snapshot.find_by(id: game3_team1_snapshot.id)).to be_nil
        expect(Snapshot.find_by(id: game3_team2_snapshot.id)).to be_nil
      end

      it "does not change snapshots from before that time" do
        league, serie, team1, team2, match1 = create_match.values_at(:league, :serie, :team1, :team2, :match1)
        game1_time, game2_time = [Date.parse("2020-01-02") + 1.hour, Date.parse("2020-01-02") + 2.hours]
        game1 = create(:game, match: match1, winner: team1, end_at: game1_time)
        _game2 = create(:game, match: match1, winner: team2, end_at: game2_time)
        game1_team1_snapshot = create(:snapshot, game: game1, datetime: game1_time, team: team1, serie: serie)
        game1_team2_snapshot = create(:snapshot, game: game1, datetime: game1_time, team: team1, serie: serie)

        described_class.new(league, game2_time).call

        expect(Snapshot.find_by(id: game1_team1_snapshot.id)).to be_present
        expect(Snapshot.find_by(id: game1_team2_snapshot.id)).to be_present
      end
    end

    context "when the league has two series in different years" do
      # Elo resets in this case are either a new_team_elo or a reverted team elo
      it "generates a elo reset for both teams in both years" do
        league = create(:league)

        serie1 = create(:serie, league: league, begin_at: "2019-06-01", year: 2019)
        tournament1 = create(:tournament, serie: serie1)
        team1, team2 = create_list(:team, 2)
        match1 = create(:match, opponent1: team1, opponent2: team2, tournament: tournament1)
        _game1 = create(:game, match: match1, winner: team1, end_at: "2019-06-02")
        
        serie2 = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)
        tournament2 = create(:tournament, serie: serie2)
        match2 = create(:match, opponent1: team1, opponent2: team2, tournament: tournament2)
        _game2 = create(:game, match: match2, winner: team2, end_at: "2020-01-02")

        described_class.call(league)
        expect(Snapshot.where(team: team1, datetime: serie1.begin_at, elo_reset: true, serie: serie1)).to be_present
        expect(Snapshot.where(team: team2, datetime: serie1.begin_at, elo_reset: true, serie: serie1)).to be_present
        expect(Snapshot.where(team: team1, datetime: serie2.begin_at, elo_reset: true, serie: serie2)).to be_present
        expect(Snapshot.where(team: team2, datetime: serie2.begin_at, elo_reset: true, serie: serie2)).to be_present
      end
    end
  end
end