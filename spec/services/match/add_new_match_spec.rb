# frozen_string_literal: true

require 'rails_helper'

RSpec.fdescribe Match::AddNewMatch do
  describe "#call" do
    subject { Match::AddNewMatch.new(match_data).call }

    let(:match_data) do
      {
        "id" => 1,
        "serie" => match_serie_data,
      }
    end

    let(:match_serie_data) do
      {
        "full_name" => "Spring 2020",
      }
    end

    context "when the match already exists" do
      let!(:existing_match) { create(:match, panda_score_id: 1) }

      it "does nothing" do
        expect { subject }.not_to change { Match.count }
      end
    end

    context "when the serie is not legitimate" do
      it "does nothing"
    end

    context "when the match does not exist" do
      it "creates the match"
      it "creates the games in the match"
      it "creates games that belong to the match"
    end

    context "when the serie does not exist" do
      it "creates a serie"
      it "creates a serie that belongs to the tournament"
    end

    context "when the tournament does not exist" do
      it "creates a tournament"
      it "creates a tournament that belongs to the league"
      it "creates teams for the tournament"
    end
  end
end