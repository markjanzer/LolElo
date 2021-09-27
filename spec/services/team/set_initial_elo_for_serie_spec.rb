# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe Team::SetInitialEloForSerie do
  describe "#call" do
    subject { Team::SetInitialEloForSerie.new(team: team, serie: serie).call }

    let!(:league) { create(:league, series: series) }
    let(:series) { [serie] }
    let(:serie) { create(:serie, tournaments: [tournament], begin_at: "2020-06-01", year: 2020) }
    let(:tournament) { create(:tournament, teams: [team]) }
    let(:team) { create(:team) }


    context "when the team has an elo from the current serie" do
      it "does nothing" do
        expect { subject }.not_to change { Snapshot.count }
      end
    end

    context "when there is no previous serie" do
      it "creates a snapshot for the team"
      it "creates a snapshot with elo of NEW_TEAM_ELO"
      it "creates a snapshot with the time of the serie begin_at"
    end

    context "when the team was not active in the previous serie" do
      it "creates a snapshot for the team"
      it "creates a snapshot with elo of NEW_TEAM_ELO"
      it "creates a snapshot with the time of the serie begin_at"
    end

    context "when the team has not gotten an elo rating this year" do
      it "creates a snapshot for the team"
      it "creates a snapshot with a elo reverted towards RESET_ELO"
      it "creates a snapshot with the time of the serie begin_at"
    end


    # context "when there is no previous serie" do
    #   it "creates a snapshot for each team in the serie" do
    #     subject
    #     expect(team.snapshots.count).to eq(1)
    #   end

    #   it "create snapshots with elo of the NEW_TEAM_ELO" do
    #     subject
    #     expect(team.snapshots.last.elo).to eq(EloCalculator::NEW_TEAM_ELO)
    #   end

    #   it "creates snapshots with the start time of the serie" do
    #     subject
    #     expect(team.snapshots.last.date).to eq(serie.begin_at)
    #   end
    # end

    # context "there is a previous serie from the same year" do
    #   let(:series) { [previous_serie, serie]}
    #   let(:previous_serie) { create(:serie, tournaments: [previous_serie_tournament], begin_at: "2020-01-01", year: 2020) }
      
    #   context "team was active in that serie" do
    #     let(:previous_serie_tournament) { create(:tournament, teams: [team]) }
    #     let!(:snapshot) { create(:snapshot, team: team, elo: 1200, date: "2020-01-01") }

    #     it "does not create a snapshot" do
    #       expect { subject }.to_not change { Snapshot.count }
    #     end
    #   end
      
    #   context "team was not active in that serie" do
    #     let(:previous_serie_tournament) { create(:tournament, teams: []) }

    #     it "creates a snapshot with a reset elo" do
    #       subject
    #       expect(team.snapshots.last.elo).to eq(EloCalculator::NEW_TEAM_ELO)
    #     end

    #     it "creates a snapshot dated to the beginning of the season" do
    #       subject
    #       expect(team.snapshots.last.date).to eq(serie.begin_at)
    #     end
    #   end
    # end

    # context "when there is a previous serie from a previous year" do
    #   let(:series) { [previous_serie, serie]}
    #   let(:previous_serie) { create(:serie, tournaments: [previous_serie_tournament], begin_at: "2019-01-01", year: 2019) }

    #   context "team was active in that serie" do
    #     let(:previous_serie_tournament) { create(:tournament, teams: [team]) }
    #     let!(:snapshot) { create(:snapshot, team: team, elo: 1200, date: "2019-01-01") }

    #     it "creates a snapshot with a elo reverted towards RESET_ELO" do
    #       reverted_elo = EloCalculator::Revert.new(team.elo).call
    #       subject
    #       expect(team.elo).to eq(reverted_elo)
    #     end

    #     it "creates an snapshot dated to the beginning of the year" do
    #       subject
    #       expect(team.snapshots.last.date).to eq("2020-01-01")
    #     end
    #   end
      
    #   context "team was not active in that serie" do
    #     let(:previous_serie_tournament) { create(:tournament, teams: []) }

    #     it "creates a snapshot with a reset elo" do
    #       subject
    #       expect(team.snapshots.last.elo).to eq(EloCalculator::NEW_TEAM_ELO)
    #     end

    #     it "creates a snapshot dated to the beginning of the season" do
    #       subject
    #       expect(team.snapshots.last.date).to eq(serie.begin_at)
    #     end
    #   end
    # end
  end
end