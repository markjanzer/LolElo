# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Updater do
  describe "#call" do
    it "calls create_new_series with each league" do
      league = create(:league)
      instance = described_class.new
      expect(instance).to receive(:create_new_series).with(league)
      instance.call
    end

    # This is a little tricky because it continues to run the code
    # Which attempts to access the API, and I don't want to spec everything out
    # This might be a little easier when I move logic around.
    it "calls create_new_tournaments with each ps_serie that hasn't finished"

    it "updates the ps_serie"
    it "does not do anything if the serie is complete"
    
    it "calls create_new_matches with each non-complete tournament"
    it "update each non-complete tournament"
    it "does nothing if the tournament is complete"

    it "calls create_new_games for each non-complete match"
    it "updates each non-complete match"
    it "does nothing if the match is complete"

    it "updates each non-complete game"
    it "does nothing if the game is complete"
  end

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
    # I think that the real next step is moving this logic out of
    # PandaScoreAPISeeder and into the model
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

  describe "#create_new_matches" do
    context "matches already exist" do
      it "does not create a match" do
        ps_tournament = create(:panda_score_tournament)
        ps_match = create(:panda_score_match)
        new_match_data = {
          "id"=>ps_match.panda_score_id
        }
        ps_tournament.data["matches"] = [new_match_data]
  
        allow(PandaScoreAPI).to receive(:matches).with(tournament_id: ps_tournament.panda_score_id).and_return([new_match_data])
        expect { described_class.new.send(:create_new_matches, ps_tournament) }.not_to change { PandaScore::Match.count }
      end
    end

    it "creates matches" do
      ps_tournament = create(:panda_score_tournament)
      new_match_data = {
        "id"=>10
      }

      allow(PandaScoreAPI).to receive(:matches).with(tournament_id: ps_tournament.panda_score_id).and_return([new_match_data])
      expect { described_class.new.send(:create_new_matches, ps_tournament) }.to change { PandaScore::Match.count }.by 1
    end
  end

  describe "#create_new_games" do
    context "games already exist" do
      it "does not create a game" do
        ps_tournament = create(:panda_score_tournament)
        ps_match = create(:panda_score_match)
        new_match_data = {
          "id"=>ps_match.panda_score_id
        }
        ps_tournament.data["matches"] = [new_match_data]

        allow(PandaScoreAPI).to receive(:matches).with(tournament_id: ps_tournament.panda_score_id).and_return([new_match_data])
        expect { described_class.new.send(:create_new_matches, ps_tournament) }.not_to change { PandaScore::Match.count }
      end
    end

    it "creates games" do
      ps_match = create(:panda_score_match)
      new_game_data = {
        "id"=>99
      }

      allow(PandaScoreAPI).to receive(:games).with(match_id: ps_match.panda_score_id).and_return([new_game_data])
      expect { described_class.new.send(:create_new_games, ps_match) }.to change { PandaScore::Game.count }.by 1
    end
  end
end