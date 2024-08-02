# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'
require 'benchmark'

RSpec.describe ChartData do
  describe "#call" do
    it "integrates methods into the response object correctly" do
      serie = create(:serie)
      instance = described_class.new(serie)
      allow(instance).to receive(:elos_at_dates).and_return("elos_at_dates")
      allow(instance).to receive(:teams_json).and_return("teams_json")
      allow(instance).to receive(:matches_data).and_return("matches_data")

      result = instance.call

      expect(result).to eq({
        data: "elos_at_dates",
        teams: "teams_json",
        matches: "matches_data"
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
      create(:snapshot, team: team1, elo: 1000, serie: serie, game: nil, datetime: serie.begin_at)
      create(:snapshot, team: team2, elo: 1000, serie: serie, game: nil, datetime: serie.begin_at)
      create(:snapshot, team: team1, elo: 1100, serie: serie, game: game, datetime: game.end_at)
      create(:snapshot, team: team2, elo: 900, serie: serie, game: game, datetime: game.end_at)

      result = described_class.new(serie).call

      # puts "user      system       total        real"
      # puts Benchmark.measure {
      #   1000.times do
      #     described_class.new(serie).call
      #   end
      # }

      elos_at_dates = result[:data]
      teams_json = result[:teams]
      matches_data = result[:matches]

      expect(elos_at_dates).to eq([
        {:name=>"Start of #{serie.full_name}", "T1"=>1000, "T2"=>1000}, 
        {:name=>"Jan 1", "T1"=>1100, "T2"=>900}
      ])
      expect(teams_json).to eq([
        team1.as_json,
        team2.as_json
      ])
      expect(matches_data).to eq([
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
end