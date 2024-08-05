# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelUpsert::Tournament do
  describe "#call" do
    context "when the tournament does not exist" do
      it "creates a tournament" do
        panda_score_tournament = create(:panda_score_tournament)
        serie = create(:serie)
        allow(panda_score_tournament).to receive(:serie).and_return(serie)
        
        expect { described_class.call(panda_score_tournament) }.to change { Tournament.count }.by(1)
      end
    end

    context "when the tournament does exist" do
      it "does not create a new tournament" do
        panda_score_tournament = create(:panda_score_tournament)
        serie = create(:serie)
        allow(panda_score_tournament).to receive(:serie).and_return(serie)

        create(:tournament, panda_score_id: panda_score_tournament.panda_score_id)

        expect { described_class.call(panda_score_tournament) }.not_to change { Tournament.count }
      end
    end

    context "when the tournament is for promotion or relegation" do
      it "does not create the tournament" do
        panda_score_tournament1 = create(:panda_score_tournament, data: { "name" => "Promotion" })
        panda_score_tournament2 = create(:panda_score_tournament, data: { "name" => "Promotion-Relegation" })
        serie = create(:serie)
        allow(panda_score_tournament1).to receive(:serie).and_return(serie)
        allow(panda_score_tournament2).to receive(:serie).and_return(serie)

        expect { described_class.new(panda_score_tournament1).call }.not_to change { Tournament.count }
        expect { described_class.new(panda_score_tournament2).call }.not_to change { Tournament.count }
      end
    end

    it "sets the tournament with correct attributes" do
      serie = create(:serie)
      panda_score_tournament = create(:panda_score_tournament, data: {
        "name" => "name",
        "serie_id" => serie.panda_score_id
      })

      described_class.call(panda_score_tournament)
      
      tournament = Tournament.last

      expect(tournament).to have_attributes(
        panda_score_id: panda_score_tournament.panda_score_id,
        name: panda_score_tournament.data["name"]
      )
    end
  end
end