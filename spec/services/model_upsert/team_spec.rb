# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ModelUpsert::Team do
  describe "#call" do
    context "when the team does not exist" do
      it "creates a team" do
        panda_score_team = create(:panda_score_team, data: { "acronym" => "C9" })
        tournament = create(:tournament)
        
        expect { described_class.call(ps_team: panda_score_team, tournament:) }.to change { Team.count }.by(1)
      end
    end

    context "when the team does exist" do
      it "does not create a new team" do
        panda_score_team = create(:panda_score_team, data: { "acronym" => "C9" })
        tournament = create(:tournament)

        create(:team, panda_score_id: panda_score_team.panda_score_id)

        expect { described_class.call(ps_team: panda_score_team, tournament:) }.not_to change { Team.count }
      end

      it "does not change the team's color" do
        panda_score_team = create(:panda_score_team, data: { "acronym" => "C9" })
        tournament = create(:tournament)

        team = create(:team, panda_score_id: panda_score_team.panda_score_id, color: "red")

        expect { described_class.call(ps_team: panda_score_team, tournament:) }.not_to change { team.reload.color }
      end
    end

    it "sets the team with correct attributes" do
      tournament = create(:tournament)
      panda_score_team = create(:panda_score_team, data: {
        "name" => "name",
        "acronym" => "AC",
        "tournament_id" => tournament.panda_score_id
      })

      described_class.call(ps_team: panda_score_team, tournament:)
      team = Team.find_by(panda_score_id: panda_score_team.panda_score_id)

      expect(team).to have_attributes(
        panda_score_id: panda_score_team.panda_score_id,
        name: panda_score_team.data["name"],
        acronym: panda_score_team.data["acronym"],
      )
      expect(Team::UNIQUE_COLORS).to include(team.color)
    end

    it "assigns the team to the tournament" do
      panda_score_team = create(:panda_score_team, data: { "acronym" => "C9" })
      tournament = create(:tournament)

      team = create(:team, panda_score_id: panda_score_team.panda_score_id)

      expect { described_class.call(ps_team: panda_score_team, tournament:) }.to change { TeamsTournament.count }.by(1)
      expect(team.reload.tournaments).to include(tournament)
    end

    it "assigns a unique team color as long as there are unique colors available" do
      tournament = create(:tournament)
      Team::UNIQUE_COLORS.length.times do 
        described_class.call(ps_team: create(:panda_score_team , data: { "acronym" => "C9" }), tournament: tournament)
      end

      expect(tournament.teams.pluck(:color)).to match_array(Team::UNIQUE_COLORS)
    end

    context "when there are more teams in a tournament than unique colors" do
      it "chooses a random color" do
        tournament = create(:tournament)
        Team::UNIQUE_COLORS.length.times do 
          described_class.call(ps_team: create(:panda_score_team, data: { "acronym" => "C9" }), tournament: tournament)
        end

        panda_score_team = create(:panda_score_team, data: { "acronym" => "CLG" })
        described_class.call(ps_team: panda_score_team, tournament: tournament)
        last_team = Team.find_by(panda_score_id: panda_score_team.panda_score_id)

        expect(Team::UNIQUE_COLORS).to include(last_team.color)
      end
    end
  end
end