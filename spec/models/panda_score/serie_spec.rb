# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::Serie do
  describe "#create_or_update_serie" do
    it "creates a serie if it doesn't exist" do
      league = create(:league, panda_score_id: 1)
      panda_score_serie = create(:panda_score_serie, data: { "league_id" => league.panda_score_id })

      expect { panda_score_serie.create_or_update_serie }.to change { Serie.count }.by 1
    end

    it "updates a serie if it exists" do
      league = create(:league, panda_score_id: 1)
      serie = create(:serie, league: league, year: 2019, begin_at: Time.parse("2019-01-01"), full_name: "Spring 2019")
      panda_score_serie = create(
        :panda_score_serie, 
        data: { 
          "league_id" => league.panda_score_id,
          "year" => "2020",
          "begin_at" => Time.parse("2020-01-01"),
          "full_name" => "Spring 2020"
        }
      )

      panda_score_serie.create_or_update_serie

      expect(serie.reload.attributes).to include(
        "year" => 2020,
        "begin_at" => Time.parse("2020-01-01"),
        "full_name" => "Spring 2020"
      )
    end

    it "sets the serie's league" do
      league = create(:league, panda_score_id: 1)
      panda_score_serie = create(:panda_score_serie, data: { "league_id" => league.panda_score_id })

      panda_score_serie.create_or_update_serie

      serie = Serie.find_by(panda_score_id: panda_score_serie.panda_score_id)
      expect(serie.league).to eq(league)
    end
  end
end