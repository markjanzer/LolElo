# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe PandaScoreAPISeeder do
  describe "#call" do

    # Ensure that we don't hit the API.
    before do 
      request_obj_double = double("PandaScoreAPI::Request")
      allow(PandaScoreAPI::Request).to receive(:new).and_return(request_obj_double)
    end

    let(:league_id) { 1 }
    let(:serie_id) { 2 } 
    let(:tournament_id) { 3 }
    let(:team_id) { 4 }
    let(:match_id) { 5 }

    let(:match_data) do
      {
        "id"=> match_id,
        "games"=> [
          {
            "id"=> 6,
          }
        ] 
      }
    end

    it "creates everything" do
      Sidekiq::Testing.inline! do
        expect(PandaScoreAPI).to receive(:league).with(id: league_id).and_return({"id" => league_id})
        expect(PandaScoreAPI).to receive(:serie).with(id: serie_id).and_return({"id" => serie_id})
        expect(PandaScoreAPI).to receive(:tournament).with(id: tournament_id).and_return({"id" => tournament_id})
        expect(PandaScoreAPI).to receive(:team).with(id: team_id).and_return({"id" => team_id})
        expect(PandaScoreAPI).to receive(:match).with(id: match_id).and_return(match_data)

        expect(PandaScoreAPI).to receive(:series).with(league_id: league_id).and_return([{"id" => serie_id}])
        expect(PandaScoreAPI).to receive(:tournaments).with(serie_id: serie_id).and_return([{"id" => tournament_id}])
        expect(PandaScoreAPI).to receive(:teams).with(tournament_id: tournament_id).and_return([{"id" => team_id}])
        expect(PandaScoreAPI).to receive(:matches).with(tournament_id: tournament_id).and_return([match_data])

        described_class.new([league_id]).call

        expect(PandaScore::League.count).to eq 1
        expect(PandaScore::Serie.count).to eq 1
        expect(PandaScore::Tournament.count).to eq 1
        expect(PandaScore::Team.count).to eq 1
        expect(PandaScore::Match.count).to eq 1
        expect(PandaScore::Game.count).to eq 1
      end
    end
  end
end