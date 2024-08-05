# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ModelUpsert::League do
  describe ".call" do
    context "when the panda_score_league does not exist" do
      it "raises an error" do
        expect { described_class.call(panda_score_league: nil, time_zone: "UTC") }.to raise_error(StandardError)
      end
    end

    context "when time_zone is nil" do
      it "raises an error" do
        ps_league = create(:panda_score_league)
        expect { described_class.call(panda_score_league: ps_league, time_zone: nil) }.to raise_error(StandardError)
      end
    end

    context "when the league does not exist" do
      it "creates a league" do
        ps_league = create(:panda_score_league, data: { "name" => "name" })

        expect { described_class.call(panda_score_league: ps_league, time_zone: "UTC") }
          .to change { League.count }.by(1)

        expect(League.last).to have_attributes(panda_score_id: ps_league.panda_score_id, name: "name", time_zone: "UTC")
      end
    end

    context "when the league exists" do
      it "updates the league" do
        ps_league = create(:panda_score_league, panda_score_id: 1, data: { "name" => "new name" })
        league = create(:league, panda_score_id: 1, name: "name", time_zone: "UTC")

        expect { described_class.call(panda_score_league: ps_league, time_zone: "UTC") }
          .to change { league.reload.name }.from("name").to("new name")
      end
    end
  end
end