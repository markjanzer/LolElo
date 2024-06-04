# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Updater do
  describe "#create_new_series" do
    context "the serie does not exist" do
      it "creates a new serie" do
        league = create(:league)
        allow(PandaScoreAPI).to receive(:series).with(league_id: league.panda_score_id).and_return([{ "id" => 1 }])
        expect { described_class.new.send(:create_new_series, league) }.to change { PandaScore::Serie.count }.by(1)
      end
    end

    context "the serie exists" do 
      it "does nothing" do
        league = create(:league)
        create(:panda_score_serie, panda_score_id: 1)
        allow(PandaScoreAPI).to receive(:series).with(league_id: league.panda_score_id).and_return([{ "id" => 1 }])
        expect { described_class.new.send(:create_new_series, league) }.not_to change { PandaScore::Serie.count }
      end
    end
  end

  describe "#create_new_tournaments" do
    context "PandaScore tournaments already exist" do
      it "does nothing" do
        ps_serie = create(:panda_score_serie)
        ps_tournament = create(:panda_score_tournament, panda_score_id: 1)
        allow(ps_serie).to receive(:panda_score_tournaments).and_return([ps_tournament]) 
        allow(PandaScoreAPI).to receive(:tournaments).with(serie_id: ps_serie.panda_score_id).and_return([{ "id"=>1 }])
        expect { described_class.new.send(:create_new_tournaments, ps_serie) }.not_to change { PandaScore::Tournament.count }
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
      expect { described_class.new.send(:create_new_tournaments, ps_serie) }.to change { PandaScore::Tournament.count }.by 1
    end

    # Maybe instead of these tests I should just ensure that
    # PandScoreAPISeeder::CreateTeam is called with each of the teams
    # That service doesn't have tests right now though
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