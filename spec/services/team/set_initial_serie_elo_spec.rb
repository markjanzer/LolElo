# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe Team::SetInitialSerieElo do
  describe "#call" do

    let!(:league) { create(:league, series: series) }
    let(:series) { [previous_serie, serie] }
    let(:serie) { create(:serie, begin_at: "2020-06-01", year: 2020) }
    let(:tournament) { create(:tournament, serie: serie) }
    let(:team) { create(:team) }
    let(:teams_tournament) { create(:teams_tournament, team: team, tournament: tournament) }
    let!(:previous_serie) { create(:serie, tournaments: [previous_serie_tournament], begin_at: "2020-01-01", year: 2020) }
    let(:previous_serie_tournament) { create(:tournament, teams: [team]) }

    def setup
      league = create(:league)
      serie = create(:serie, league: league, begin_at: "2020-06-01", year: 2020)
      tournament = create(:tournament, serie: serie)
      team = create(:team)
      create(:teams_tournament, team: team, tournament: tournament)

      # pervious_serie = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)
      # pervious_tournament = create(:tournament, serie: pervious_serie)
      # create(:teams_tournament, team: team, tournament: pervious_tournament)

      { 
        league: league, 
        serie: serie, 
        # pervious_serie: pervious_serie, 
        tournament: tournament, 
        # pervious_tournament: pervious_tournament, 
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

    context "when the team has a elo from a previous serie this year" do
      it "does nothing" do
        setup => { team:, serie: }
        previous_serie = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)
        previous_tournament = create(:tournament, serie: previous_serie)
        create(:teams_tournament, team: team, tournament: previous_tournament)
        create(:snapshot, elo: 1500, team: team, datetime: previous_serie.begin_at)
        expect { described_class.new(team: team, serie: serie).call }.not_to change { Snapshot.count }
      end
    end

    context "when there is no previous serie" do
      let(:previous_serie) { nil }
      let(:series) { [serie] }

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

      it "creates a snapshot that is an elo_reset" do
        described_class.new(team: team, serie: serie).call
        expect(Snapshot.last.elo_reset).to be true
      end

      it "creates a snapshot with the time of the serie begin_at" do
        described_class.new(team: team, serie: serie).call
        expect(Snapshot.last.datetime).to eq serie.begin_at
      end
    end

    context "when the team was not active in the previous serie" do
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
      let!(:previous_serie) { create(:serie, tournaments: [previous_serie_tournament], begin_at: "2019-06-01", year: 2019) }
      let(:previous_serie_tournament) { create(:tournament, teams: [team]) }
      let!(:snapshot) { create(:snapshot, team: team, elo: 1200, datetime: "2019-06-01") }

      it "creates a snapshot for the team" do
        expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1
      end

      it "creates a snapshot with a elo reverted towards RESET_ELO" do
        reverted_elo = EloCalculator::Revert.new(team.elo).call
        described_class.new(team: team, serie: serie).call
        expect(team.elo).to eq(reverted_elo)
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
  end
end