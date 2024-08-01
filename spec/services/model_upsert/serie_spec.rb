# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ModelUpsert::Serie do
  describe "#call" do
    context "when the serie does not exist" do
      it "creates a serie" do
        panda_score_serie = create(:panda_score_serie)
        league = create(:league)
        allow(panda_score_serie).to receive(:league).and_return(league)

        instance = described_class.new(panda_score_serie)
        allow(instance).to receive(:valid_serie?).and_return(true)
        
        expect { instance.call }.to change { Serie.count }.by(1)
      end
    end

    context "when the serie does exist" do
      it "does not create a new serie" do
        panda_score_serie = create(:panda_score_serie)
        league = create(:league)
        allow(panda_score_serie).to receive(:league).and_return(league)

        instance = described_class.new(panda_score_serie)
        allow(instance).to receive(:valid_serie?).and_return(true)

        serie = create(:serie, panda_score_id: panda_score_serie.panda_score_id)

        expect { instance.call }.not_to change { Serie.count }
      end
    end

    it "sets the serie with correct attributes" do
      league = create(:league)
      time = Time.parse("2020-01-01")
      panda_score_serie = create(:panda_score_serie, data: {
        "year" => 2020,
        "begin_at" => time,
        "full_name" => "Spring 2020",
        "league_id" => league.panda_score_id
      })

      described_class.new(panda_score_serie).call
      
      serie = Serie.last

      expect(serie).to have_attributes(
        panda_score_id: panda_score_serie.panda_score_id,
        year: panda_score_serie.data["year"],
        begin_at: time,
        full_name: panda_score_serie.data["full_name"],
        league: league
      )
    end
  end

  # Testing a private method against some advice. Let's see how it turns out :)
  describe "#valid_serie?" do
    it "is true for serie when the name starts with 'Spring' or 'Summer'" do
      panda_score_serie1 = double(data: { "full_name" => "Spring 2020" })
      panda_score_serie2 = double(data: { "full_name" => "Summer 2020" })

      expect(described_class.new(panda_score_serie1).send(:valid_serie?)).to eq(true)
      expect(described_class.new(panda_score_serie2).send(:valid_serie?)).to eq(true)
    end

    it "returns false if they do not" do
      panda_score_serie = double(data: { "full_name" => "Winter 2020" })

      expect(described_class.new(panda_score_serie).send(:valid_serie?)).to eq(false)
    end
  end
end