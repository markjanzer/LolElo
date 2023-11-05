# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ApplicationSeeder::CreateSeries do
  describe "#call" do
    it "creates series for a league" do
      panda_score_league_id = 1
      
      league = create(:league, panda_score_id: panda_score_league_id)

      panda_score_league = create(
        :panda_score_league,
        panda_score_id: panda_score_league_id,
        data: { 
          "id" => panda_score_league_id, 
          "series" => [{ "id" => 2 }]
        }      
      )

      panda_score_serie = create(
        :panda_score_serie,
        panda_score_id: 2,
        data: { 
          "id" => 2, 
          "full_name" => "Spring 2020", 
          "begin_at" => Time.parse("2020-01-01"), 
          "year" => "2020",
          "league_id" => panda_score_league_id
        }
      )
      
      expect { described_class.new(panda_score_league_id).call }.to change { Serie.count }.by(1)

      expect(Serie.last).to have_attributes(
        panda_score_id: 2,
        year: "2020".to_i,
        begin_at: Time.parse("2020-01-01"),
      )
    end

    it "doesn't create leagues that aren't Spring or Summer" do
      panda_score_league_id = 1
      
      league = create(:league, panda_score_id: panda_score_league_id)

      panda_score_league = create(
        :panda_score_league,
        panda_score_id: panda_score_league_id,
        data: { 
          "id" => panda_score_league_id, 
          "series" => [{ "id" => 2 }]
        }      
      )

      panda_score_serie = create(
        :panda_score_serie,
        panda_score_id: 2,
        data: { "id" => 2, "full_name" => "Fall 2020", "begin_at" => Time.parse("2020-01-01"), "year" => "2020"}
      )

      expect { described_class.new(panda_score_league_id).call }.to_not change { Serie.count }
    end
  end
end