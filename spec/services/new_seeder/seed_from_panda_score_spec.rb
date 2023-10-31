# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe NewSeeder::SeedFromPandaScore do
  describe "#call" do
    it "calls the create_leagues service for each league id" do
      NewSeeder::SeedFromPandaScore::LEAGUE_IDS.each do |league_id|
        expect(NewSeeder::CreateLeague).to receive(:new).with(league_id).and_call_original
      end

      allow_any_instance_of(NewSeeder::CreateLeague).to receive(:call)
      
      described_class.new.call
    end
  end
end