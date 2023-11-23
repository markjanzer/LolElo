# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ChartData do
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
  end

  describe "#elos_at_dates" do
    
  end


  describe "#teams_json" do
  end

  describe "#match_data" do

  end
end