# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe Team::SetInitialSerieElo do
  describe "#call" do
    subject { Team::SetInitialSerieElo.new(team: team, serie: serie).call }

    let!(:league) { create(:league, series: series) }
    let(:series) { [previous_serie, serie] }
    let(:serie) { create(:serie, tournaments: [tournament], begin_at: "2020-06-01", year: 2020) }
    let(:tournament) { create(:tournament, teams: [team]) }
    let(:team) { create(:team) }
    let!(:previous_serie) { create(:serie, tournaments: [previous_serie_tournament], begin_at: "2020-01-01", year: 2020) }
    let(:previous_serie_tournament) { create(:tournament, teams: [team]) }


    context "when the team has an elo from the current serie" do
      let!(:snapshot) { create(:snapshot, elo: 1500, team: team, date: "2020-06-01") }
      
      it "does nothing" do
        expect { subject }.not_to change { Snapshot.count }
      end
    end

    context "when the team has a elo from a previous serie this year" do
      it "does nothing" do
        expect { subject }.not_to change { Snapshot.count }
      end
    end

    context "when there is no previous serie" do
      let(:previous_serie) { nil }
      let(:series) { [serie] }

      it "creates a snapshot for the team" do
        expect { subject }.to change { Snapshot.count }.by 1
      end

      it "creates a snapshot with elo of NEW_TEAM_ELO" do
        subject
        expect(Snapshot.last.elo).to eq(EloCalculator::NEW_TEAM_ELO)
      end

      it "creates a snapshot with the time of the serie begin_at" do
        subject
        expect(Snapshot.last.date).to eq serie.begin_at
      end
    end

    context "when the team was not active in the previous serie" do
      let(:previous_serie_tournament) { create(:tournament, teams: []) }

      it "creates a snapshot for the team" do
        expect { subject }.to change { Snapshot.count }.by 1
      end

      it "creates a snapshot with elo of NEW_TEAM_ELO" do
        subject
        expect(Snapshot.last.elo).to eq(EloCalculator::NEW_TEAM_ELO)
      end

      it "creates a snapshot with the time of the serie begin_at" do
        subject
        expect(Snapshot.last.date).to eq serie.begin_at
      end
    end

    context "when the team has not gotten an elo rating this year" do
      let!(:previous_serie) { create(:serie, tournaments: [previous_serie_tournament], begin_at: "2019-06-01", year: 2019) }
      let(:previous_serie_tournament) { create(:tournament, teams: [team]) }
      let!(:snapshot) { create(:snapshot, team: team, elo: 1200, date: "2019-06-01") }

      it "creates a snapshot for the team" do
        expect { subject }.to change { Snapshot.count }.by 1
      end

      it "creates a snapshot with a elo reverted towards RESET_ELO" do
        reverted_elo = EloCalculator::Revert.new(team.elo).call
        subject
        expect(team.elo).to eq(reverted_elo)
      end

      it "creates a snapshot with the time of the serie begin_at" do
        subject
        expect(Snapshot.last.date).to eq serie.begin_at
      end
    end
  end
end