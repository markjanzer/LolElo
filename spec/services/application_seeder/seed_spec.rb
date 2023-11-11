# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ApplicationSeeder::Seed do
  describe "#call" do
    it "calls all the create methods" do
      instance = described_class.new

      expect(instance).to receive(:create_leagues).with(described_class::LEAGUE_SEED_DATA).and_return(nil)
      expect(instance).to receive(:create_all_series).and_return(nil)
      expect(instance).to receive(:create_all_tournaments).and_return(nil)
      expect(instance).to receive(:create_all_teams).and_return(nil)
      expect(instance).to receive(:create_all_matches).and_return(nil)
      expect(instance).to receive(:create_all_games).and_return(nil)

      instance.call
    end
  end

  describe "#reset" do
    it "destroys all the models" do
      expect(Snapshot).to receive(:destroy_all)
      expect(Game).to receive(:destroy_all)
      expect(Match).to receive(:destroy_all)
      expect(Team).to receive(:destroy_all)
      expect(Tournament).to receive(:destroy_all)
      expect(Serie).to receive(:destroy_all)
      expect(League).to receive(:destroy_all)

      described_class.new.reset
    end
  end

  describe "#create_leagues" do
    it "calls CreateOrUpdateLeague with the seed data" do
      league_seed_data = [
        { league_id: 1, time_zone: "America/Los_Angeles" },
      ]

      double = double("CreateOrUpdateLeague")
      expect(ApplicationSeeder::CreateOrUpdateLeague).to receive(:new).with(
        panda_score_id: 1,
        time_zone: "America/Los_Angeles"
      ).and_return(double)

      expect(double).to receive(:call)

      described_class.new.send(:create_leagues, league_seed_data)
    end
  end

  describe "#create_all_series" do
    it "calls CreateOrUpdateSerie for all series belonging to the leagues" do
      league = create(:league)
      panda_score_league = create(:panda_score_league)
      panda_score_series = create_list(:panda_score_serie, 2)

      allow(league).to receive(:panda_score_league).and_return(panda_score_league)
      allow(panda_score_league).to receive(:panda_score_series).and_return(panda_score_series)

      double = double("CreateOrUpdateSerie")
      
      expect(ApplicationSeeder::CreateOrUpdateSerie).to receive(:new).with(
        panda_score_series[0]
      ).and_return(double)

      expect(ApplicationSeeder::CreateOrUpdateSerie).to receive(:new).with(
        panda_score_series[1]
      ).and_return(double)

      expect(double).to receive(:call).twice

      described_class.new.send(:create_all_series, [league])
    end
  end

  describe "#create_all_tournaments" do
    it "calls CreateOrUpdateTournament for all tournaments belonging to the series" do
      serie = create(:serie)
      panda_score_serie = create(:panda_score_serie)
      panda_score_tournaments = create_list(:panda_score_tournament, 1)

      allow(serie).to receive(:panda_score_serie).and_return(panda_score_serie)
      allow(panda_score_serie).to receive(:panda_score_tournaments).and_return(panda_score_tournaments)

      double = double("CreateOrUpdateTournament")

      expect(ApplicationSeeder::CreateOrUpdateTournament).to receive(:new).with(
        panda_score_tournaments[0]
      ).and_return(double)

      expect(double).to receive(:call).once

      described_class.new.send(:create_all_tournaments, [serie])
    end
  end

  describe "#create_all_teams" do
    it "calls CreateOrUpdateTeam for all teams belonging to the tournaments" do
      tournament = create(:tournament)
      panda_score_tournament = create(:panda_score_tournament)
      panda_score_teams = create_list(:panda_score_team, 1)

      allow(tournament).to receive(:panda_score_tournament).and_return(panda_score_tournament)
      allow(panda_score_tournament).to receive(:panda_score_teams).and_return(panda_score_teams)

      double = double("CreateOrUpdateTeam")

      expect(ApplicationSeeder::CreateOrUpdateTeam).to receive(:new).with(
        panda_score_teams[0]
      ).and_return(double)

      expect(double).to receive(:call).once

      described_class.new.send(:create_all_teams, [tournament])
    end
  end

  describe "#create_all_matches" do
    it "calls CreateOrUpdateMatch for all matches belonging to the tournaments" do
      tournament = create(:tournament)
      panda_score_tournament = create(:panda_score_tournament)
      panda_score_matches = create_list(:panda_score_match, 1)

      allow(tournament).to receive(:panda_score_tournament).and_return(panda_score_tournament)
      allow(panda_score_tournament).to receive(:panda_score_matches).and_return(panda_score_matches)

      double = double("CreateOrUpdateMatch")

      expect(ApplicationSeeder::CreateOrUpdateMatch).to receive(:new).with(
        panda_score_matches[0]
      ).and_return(double)

      expect(double).to receive(:call).once

      described_class.new.send(:create_all_matches, [tournament])
    end
  end

  describe "#create_all_games" do
    it "calls CreateOrUpdateGame for all games belonging to the matches" do
      match = create(:match)
      panda_score_match = create(:panda_score_match)
      panda_score_games = create_list(:panda_score_game, 1)

      allow(match).to receive(:panda_score_match).and_return(panda_score_match)
      allow(panda_score_match).to receive(:panda_score_games).and_return(panda_score_games)

      double = double("CreateOrUpdateGame")

      expect(ApplicationSeeder::CreateOrUpdateGame).to receive(:new).with(
        panda_score_games[0]
      ).and_return(double)

      expect(double).to receive(:call).once

      described_class.new.send(:create_all_games, [match])
    end
  end
end