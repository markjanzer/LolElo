# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe Team::SetInitialSerieElo do
  describe "#call" do

    def setup
      league = create(:league)
      serie = create(:serie, league: league, begin_at: "2020-06-01", year: 2020)
      tournament = create(:tournament, serie: serie)
      team = create(:team)
      create(:teams_tournament, team: team, tournament: tournament)

      { 
        league: league, 
        serie: serie, 
        tournament: tournament, 
        team: team
      }
    end

    context "when the team has an elo from the current serie" do
      it "does nothing" do
        setup => { team:, serie: }
        create(:snapshot, team: team, serie: serie)
        expect { described_class.new(team: team, serie: serie).call }.not_to change { Snapshot.count }
      end
    end

    context "when the team has an elo from another serie in the same year" do
      it "does nothing" do
        setup => { team:, serie: }

        other_serie = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)
        # Not sure if this works
        create(:snapshot, team: team, serie: other_serie)

        expect { described_class.new(team: team, serie: serie).call }.not_to change { Snapshot.count }
      end
    end

    context "when the team no elo from the current year" do
      context "when the team has elo from the previous year" do
        it "creates a snapshot with reset elo" do
          setup => { team:, serie: }

          old_serie = create(:serie, league: league, begin_at: "2019-01-01", year: 2019)
          old_snapshot = create(:snapshot, elo: 1200, team: team, serie: old_serie)

          reverted_elo = EloCalculator::Revert.new(old_snapshot.elo).call

          expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1

          snapshot = Snapshot.last
          expect(snapshot.elo).to eq(reverted_elo)
        end

        it "creates a snapshot with correct attributes" do
          setup => { team:, serie: }

          old_serie = create(:serie, league: league, begin_at: "2019-01-01", year: 2019)
          old_snapshot = create(:snapshot, elo: 1200, team: team, serie: old_serie)

          reverted_elo = EloCalculator::Revert.new(old_snapshot.elo).call

          described_class.new(team: team, serie: serie).call

          snapshot = Snapshot.last
          expect(snapshot).to have_attributes(
            team: team,
            serie: serie,
            elo_reset: true,
            datetime: serie.begin_at,
            elo: reverted_elo
          )          
        end
      end

      context "when the team does not have elo from the previous year" do
        it "creates a snapshot with new_team elo" do
          setup => { team:, serie: }

          expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1

          snapshot = Snapshot.last
          expect(snapshot.elo).to eq(EloCalculator::NEW_TEAM_ELO)
        end

        it "creates a snapshot with the correct attributes" do
          setup => { team:, serie: }

          described_class.new(team: team, serie: serie).call

          snapshot = Snapshot.last
          expect(snapshot).to have_attributes(
            team: team,
            serie: serie,
            elo_reset: true,
            datetime: serie.begin_at,
            elo: EloCalculator::NEW_TEAM_ELO
          )
        end
      end
    end
  end
end