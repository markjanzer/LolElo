# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::Tournament do
  describe "#serie" do
    it "returns the serie from the data" do
      serie = create(:serie)
      panda_score_tournament = create(:panda_score_tournament, data: { "serie_id" => serie.panda_score_id })

      expect(panda_score_tournament.serie).to eq(serie)
    end
  end

  describe "#create_teams" do
    context "the tournament's teams already exist" do
      it "does not create a team" do
        ps_serie = create(:panda_score_serie)
        ps_team = create(:panda_score_team, panda_score_id: 2)
        new_tournament_data = {
          "id"=>100,
          "teams"=>[
            {
              "id"=>ps_team.panda_score_id,
              "name"=>"C9"
            }
          ]
        }
        allow(PandaScoreAPI).to receive(:tournaments).with(serie_id: ps_serie.panda_score_id).and_return([new_tournament_data])
        expect { described_class.new.send(:create_new_tournaments, ps_serie) }.not_to change { PandaScore::Team.count }
      end
    end

    it "creates a team" do
      ps_serie = create(:panda_score_serie)
      team_data = {
        "id"=>2,
        "name"=>"C9"
      }
      new_tournament_data = {
        "id"=>100,
        "teams"=>[team_data]
      }
      allow(PandaScoreAPI).to receive(:tournaments).with(serie_id: ps_serie.panda_score_id).and_return([new_tournament_data])
      allow(PandaScoreAPI).to receive(:team).with(id: team_data["id"]).and_return(team_data)
      expect { described_class.new.send(:create_new_tournaments, ps_serie) }.to change { PandaScore::Team.count }.by 1
    end
  end
end