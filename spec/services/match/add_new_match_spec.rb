# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Match::AddNewMatch do
  describe "#call" do
    context "when the match already exists" do
      it "does nothing"
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