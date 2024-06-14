# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::Match do
  describe "#tournament" do
    it "returns the tournament from the data" do
      tournament = create(:tournament)
      panda_score_match = create(:panda_score_match, data: { "tournament_id" => tournament.panda_score_id })

      expect(panda_score_match.tournament).to eq(tournament)
    end
  end

  # This might break now
  describe "#create_or_update_games" do
    it "creates games" do
      ps_match = create(:panda_score_match, data: {
        "games"=>[
          {"id"=>99}
        ]
      })
      
      expect { ps_match.create_or_update_games }.to change { PandaScore::Game.count }.by 1
    end

    # This test was working when run locally but not when run with
    # the full test suite. I think it has to do with ps_id uniqueness
    it "updates existing games" do
      ps_match = create(:panda_score_match, data: {
        "games"=>[
          {
            "id"=>1,
            "new_data"=> "new"
          }
        ]
      })
      ps_game = create(:panda_score_game, panda_score_id: 1, data: {
        "id"=>1,
        "match_id"=>ps_match.panda_score_id,
        "new_data"=>"old"
      })

      expect { ps_match.create_or_update_games }.not_to change { PandaScore::Game.count }
      expect(ps_game.reload.data["new_data"]).to eq("new")
    end
  end
end