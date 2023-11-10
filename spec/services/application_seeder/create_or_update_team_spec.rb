# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ApplicationSeeder::CreateOrUpdateTeam do
  describe "#call" do
    context "when the team does not exist" do
      it "creates a team" do
        panda_score_team = create(:panda_score_team)
        tournament = create(:tournament)
        allow(panda_score_team).to receive(:tournament).and_return(tournament)
        
        expect { described_class.new(panda_score_team).call }.to change { Team.count }.by(1)
      end
    end

    context "when the team does exist" do
      it "does not create a new team" do
        panda_score_team = create(:panda_score_team)
        tournament = create(:tournament)
        allow(panda_score_team).to receive(:tournament).and_return(tournament)

        team = create(:team, panda_score_id: panda_score_team.panda_score_id)

        expect { described_class.new(panda_score_team).call }.not_to change { Team.count }
      end
    end

    it "sets the team with correct attributes" do
      tournament = create(:tournament)
      panda_score_team = create(:panda_score_team, data: {
        "name" => "name",
        "acronym" => "AC",
        "tournament_id" => tournament.panda_score_id
      })

      instance = described_class.new(panda_score_team)

      allow(instance).to receive(:unique_team_color).and_return("red")

      instance.call
      
      team = Team.last

      expect(team).to have_attributes(
        panda_score_id: panda_score_team.panda_score_id,
        name: panda_score_team.data["name"],
        acronym: panda_score_team.data["acronym"],
        color: "red"
      )
    end

    it "does something when there are no valid colors left"
  end
end