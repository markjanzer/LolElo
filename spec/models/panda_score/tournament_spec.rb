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
        ps_team = create(:panda_score_team)
        ps_tournament = create(:panda_score_tournament, data: {
          "teams"=>[
            {
              "id"=>ps_team.panda_score_id,
              "name"=>"C9"
            }
          ]
        })
        expect { ps_tournament.create_teams }.not_to change { PandaScore::Team.count }
      end
    end

    it "creates a team" do
      team_data = {
        "id"=>1,
        "name"=>"C9"
      }
      ps_tournament = create(:panda_score_tournament, data: {
        "teams"=>[team_data]
      })
      allow(PandaScoreAPI).to receive(:team).with(id: team_data["id"]).and_return team_data
      expect { ps_tournament.create_teams }.to change { PandaScore::Team.count }.by 1
    end
  end

  describe "#create_matches" do
    context "matches already exist" do
      it "does not create a match" do
        ps_tournament = create(:panda_score_tournament)
        ps_match = create(:panda_score_match, panda_score_id: 1, data: {
          "id"=>1,
          "tournament_id"=>ps_tournament.panda_score_id
        })

        allow(PandaScoreAPI).to receive(:matches).with(tournament_id: ps_tournament.panda_score_id).and_return([ps_match.data])
        expect { ps_tournament.create_matches }.not_to change { PandaScore::Match.count }
      end
    end

    it "creates matches" do
      ps_tournament = create(:panda_score_tournament)
      new_match_data = {
        "id"=>10
      }

      allow(PandaScoreAPI).to receive(:matches).with(tournament_id: ps_tournament.panda_score_id).and_return([new_match_data])
      expect { ps_tournament.create_matches }.to change { PandaScore::Match.count }.by 1
    end
  end
end