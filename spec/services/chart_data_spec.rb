# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ChartData do
  def setup
    serie = create(:serie, begin_at: DateTime.parse("2020-01-01"), full_name: "Serie Name")
    tournament = create(:tournament, serie: serie)
    team1 = create(:team)
    team2 = create(:team)
    create(:teams_tournament, team: team1, tournament: tournament)
    create(:teams_tournament, team: team2, tournament: tournament)
    match = create(:match, tournament: tournament, opponent1: team1, opponent2: team2, end_at: DateTime.parse("2020-01-01") + 2.hours)
    game = create(:game, match: match, winner: team1, end_at: DateTime.parse("2020-01-01") + 2.hours)
    create(:snapshot, team: team1, elo: 1000, datetime: serie.begin_at)
    create(:snapshot, team: team2, elo: 1000, datetime: serie.begin_at)
    create(:snapshot, team: team1, elo: 1100, datetime: game.end_at)
    create(:snapshot, team: team2, elo: 900, datetime: game.end_at)

    return { serie:, tournament:, team1:, team2:, match:, game: }
  end
  
  describe "#call" do
    it "integrates methods into the response object correctly" do
      instance = described_class.new("fake_serie")
      allow(instance).to receive(:elos_at_dates).and_return("elos_at_dates")
      allow(instance).to receive(:teams_json).and_return("teams_json")
      allow(instance).to receive(:match_data).and_return("match_data")

      result = instance.call

      expect(result).to eq({
        data: "elos_at_dates",
        teams: "teams_json",
        matches: "match_data"
      })
    end

    it "returns the same value it used to" do
      serie = create(:serie, begin_at: DateTime.parse("2020-01-01"), full_name: "Serie Name")
      tournament = create(:tournament, serie:)
      team1 = create(:team, acronym: "T1")
      team2 = create(:team, acronym: "T2")
      create(:teams_tournament, team: team1, tournament:)
      create(:teams_tournament, team: team2, tournament:)
      match = create(:match, tournament: tournament, opponent1: team1, opponent2: team2, end_at: DateTime.parse("2020-01-01") + 2.hours)
      game = create(:game, match: match, winner: team1, end_at: DateTime.parse("2020-01-01") + 2.hours)
      create(:snapshot, team: team1, elo: 1000, datetime: serie.begin_at)
      create(:snapshot, team: team2, elo: 1000, datetime: serie.begin_at)
      create(:snapshot, team: team1, elo: 1100, datetime: game.end_at)
      create(:snapshot, team: team2, elo: 900, datetime: game.end_at)

      result = described_class.new(serie).call
      pp result

      elos_at_dates = result[:data]
      teams_json = result[:teams]
      match_data = result[:matches]

      expect(elos_at_dates).to eq([
        {:name=>"Start of #{serie.full_name}", "T1"=>1000, "T2"=>1000}, 
        {:name=>"Jan 1", "T1"=>1100, "T2"=>900}
      ])
      expect(teams_json).to eq([
        team1.attributes.slice("id", "name", "acronym", "panda_score_id", "color"),
        team2.attributes.slice("id", "name", "acronym", "panda_score_id", "color")
      ])
      expect(match_data).to eq([
        {
          :date=>"Jan 1", 
          :opponent1=>team1, 
          :opponent2=>team2, 
          :opponent1_elo=>1000, 
          :opponent2_elo=>1000, 
          :opponent1_elo_change=>100, 
          :opponent2_elo_change=>-100, 
          :opponent1_score=>1, 
          :opponent2_score=>0, 
          :victor=>team1
        }
      ])
    end
  end

  describe "#elos_at_dates" do
    it "does the thing"
    it "takes serie's timezone into account"
  end


  describe "#teams_json" do
    it "does the thing"
  end

  describe "#match_data" do
    it "does te thing"
  end
end