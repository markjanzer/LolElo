# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::Serie do
  describe "#league" do
    it "returns the league from the data" do
      league = create(:league)
      panda_score_serie = create(:panda_score_serie, data: { "league_id" => league.panda_score_id })

      expect(panda_score_serie.league).to eq(league)
    end
  end

  describe "#create_tournaments" do
    context "PandaScore tournaments already exist" do
      it "does nothing" do
        ps_serie = create(:panda_score_serie)
        ps_tournament = create(:panda_score_tournament, panda_score_id: 1)
        allow(ps_serie).to receive(:panda_score_tournaments).and_return([ps_tournament]) 
        allow(PandaScoreAPI).to receive(:tournaments).with(serie_id: ps_serie.panda_score_id).and_return([{ "id"=>1 }])
        expect { ps_serie.create_tournaments }.not_to change { PandaScore::Tournament.count }
      end
    end

    it "creates a tournament" do
      ps_serie = create(:panda_score_serie)
      team_id = 2
      new_tournament_data = {
        "id"=>1,
        "teams"=>[{ "id"=>team_id }]
      }
      allow(PandaScore::Team).to receive(:exists?).with(panda_score_id: team_id).and_return true
      allow(PandaScoreAPI).to receive(:tournaments).with(serie_id: ps_serie.panda_score_id).and_return([new_tournament_data])
      expect { ps_serie.create_tournaments }.to change { PandaScore::Tournament.count }.by 1
    end

    it "calls create_teams on the new tournament" do
      ps_serie = create(:panda_score_serie)
      new_tournament_data = {
        "id"=>1,
        "teams"=>[{ "id"=>2 }]
      }
      allow(PandaScoreAPI).to receive(:tournaments).with(serie_id: ps_serie.panda_score_id).and_return([new_tournament_data])
      expect_any_instance_of(PandaScore::Tournament).to receive(:create_teams)
      ps_serie.create_tournaments
    end
  end
end