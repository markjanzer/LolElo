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
        create(:snapshot, elo: 1500, team: team, datetime: serie.begin_at) 
        expect { described_class.new(team: team, serie: serie).call }.not_to change { Snapshot.count }
      end
    end

    context "when the previous serie for this team was in another year" do
      it "does nothing" do
        setup => { team:, serie:, league: }
        previous_serie = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)
        previous_tournament = create(:tournament, serie: previous_serie)
        create(:teams_tournament, team: team, tournament: previous_tournament)
        create(:snapshot, elo: 1500, team: team, datetime: previous_serie.begin_at, serie: previous_serie)

        expect { described_class.new(team: team, serie: serie).call }.not_to change { Snapshot.count }
      end
    end

    context "when there is no previous serie" do
      it "creates a snapshot for the team" do
        setup => { team:, serie: }
        expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1
      end

      it "creates a snapshot the correct attrbutes" do
        setup => { team:, serie: }
        described_class.new(team: team, serie: serie).call
        expect(Snapshot.last).to have_attributes(
          team: team,
          serie: serie,
          elo_reset: true,
          datetime: serie.begin_at,
          elo: EloCalculator::NEW_TEAM_ELO
        )
      end
    end

    xcontext "when the team was not active in the previous serie" do
      let(:previous_serie_tournament) { create(:tournament, teams: []) }

      it "creates a snapshot for the team" do
        expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1
      end

      it "creates a snapshot with elo of NEW_TEAM_ELO" do
        described_class.new(team: team, serie: serie).call
        expect(Snapshot.last.elo).to eq(EloCalculator::NEW_TEAM_ELO)
      end

      it "creates a snapshot that belongs to the serie" do
        described_class.new(team: team, serie: serie).call
        expect(Snapshot.last.serie).to eq serie
      end

      it "creates a snapshots that is an elo_reset" do
        described_class.new(team: team, serie: serie).call
        expect(Snapshot.last.elo_reset).to be true
      end

      it "creates a snapshot with the time of the serie begin_at" do
        described_class.new(team: team, serie: serie).call
        expect(Snapshot.last.datetime).to eq serie.begin_at
      end
    end

    context "when the team has not gotten an elo rating this year" do
      it "creates a snapshot for the team" do
        setup => { team:, serie:, league: }

        previous_serie = create(:serie, league: league, begin_at: "2019-06-01", year: 2019)
        previous_tournament = create(:tournament, serie: previous_serie)
        create(:teams_tournament, team: team, tournament: previous_tournament)
        create(:snapshot, elo: 1200, team: team, datetime: previous_serie.begin_at, serie: previous_serie)

        expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1
      end

      it "creates a snapshot with correct attributes" do
        setup => { team:, serie:, league: }

        previous_serie = create(:serie, league: league, begin_at: "2019-06-01", year: 2019)
        previous_tournament = create(:tournament, serie: previous_serie)
        create(:teams_tournament, team: team, tournament: previous_tournament)
        create(:snapshot, elo: 1200, team: team, datetime: previous_serie.begin_at, serie: previous_serie)
        
        reverted_elo = EloCalculator::Revert.new(team.elo).call
        described_class.new(team: team, serie: serie).call
        expect(team.elo).to eq(reverted_elo)
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
  end
end