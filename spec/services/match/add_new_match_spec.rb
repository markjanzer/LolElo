# frozen_string_literal: true

require 'rails_helper'

RSpec.fdescribe Match::AddNewMatch do
  describe "#call" do
    subject { Match::AddNewMatch.new(match_data).call }

    let(:match_data) do
      {
        "id" => 1,
        "league_id" => 1,
        "serie_id" => 1,
        "tournament_id" => 1,
        "serie" => match_serie_data,
        "tournament" => tournament_data,
        "teams" => team_data,
        "opponents" => opponents_data,
        "games" => games_data,
      }
    end

    let(:match_serie_data) do
      {
        "full_name" => "Spring 2020",
      }
    end

    let(:tournament_data) do
      {
        "id" => 1,
        "name" => "Regular Season"
      }
    end

    let(:team_data) do
      [
        {
          "id" => 1,
          "name" => "Cloud9",
          "acronym" => "C9"
        },
        {
          "id" => 2,
          "name" => "Golden Guardians",
          "acronym" => "GG"
        },
      ]
    end

    let(:opponents_data) do
      [
        { 
          "opponent" => {
            "id" => 1
          }
        },
        {
          "opponent" => {
            "id" => 2
          }
        }
      ]
    end

    let(:games_data) do
      [
        {
          "end_at" => Date.current - 5.days,
          "winner" => {
            "id" => 1
          }
        }
      ]
    end

    let!(:league) { create(:league, panda_score_id: 1) }
    let!(:serie) { create(:serie, panda_score_id: 1, league: league) }
    let!(:tournament) { create(:tournament, panda_score_id: 1, serie: serie) }
    let!(:team1) { create(:team, panda_score_id: 1, name: "Cloud9", acronym: "C9") }
    let!(:team2) { create(:team, panda_score_id: 2, name: "Golden Guardians", acronym: "GG") }

    context "when the match already exists" do
      let!(:existing_match) { create(:match, panda_score_id: 1) }

      it "does nothing" do
        expect { subject }.not_to change { Match.count }
      end
    end

    context "when the serie is not legitimate" do
      let(:match_serie_data) do
        {
          "full_name" => "Promotion 2020"
        }
      end
      
      it "does nothing" do
        expect { subject }.not_to change { Match.count }
      end
    end

    context "when the serie does not exist" do
      let(:serie) { nil }
      let(:tournament) { nil }

      it "creates a serie" do
        expect { subject }.to change { Serie.count }.by 1
      end
      
      it "creates a serie that belongs to the league" do
        subject
        expect(Serie.last.league).to eq league
      end
    end

    context "when the tournament does not exist" do
      let(:tournament) { nil }

      it "creates a tournament" do
        expect { subject }.to change { Tournament.count }.by 1
      end

      it "creates a tournament that belongs to the serie" do
        subject
        expect(Tournament.last.serie).to eq serie
      end

      it "creates teams for the tournament" do
        subject
        expect(Tournament.last.teams.length).to eq 2
      end
    end

    context "when the match does not exist" do
      it "creates the match" do
        expect { subject }.to change { Match.count }.by 1
      end

      it "creates the games in the match" do
        expect(subject.games.length).to eq 1
      end

      it "creates games that belong to the match" do
        match = subject
        expect(match.games.first.match).to eq match
      end

      context "the teams already exist" do
        it "does not create new teams" do
          expect { subject }.not_to change { Team.count }
        end

        context "the teams belongs to the tournament" do
          let!(:teams_tournament_1) { create(:teams_tournament, team: team1, tournament: tournament) }
          let!(:teams_tournament_2) { create(:teams_tournament, team: team2, tournament: tournament) }

          it "does not add the teams to the tournament" do
            expect { subject }.not_to change { tournament.teams.count }
          end
        end

        context "the teams don't belong to the tournament" do
          it "adds the teams to the tournament" do
            expect { subject }.to change { tournament.reload.teams.count }.by 2
          end
        end
      end

      context "the teams do not exist" do
        it "creates new teams"
        it "assigns the teams to the tournament"
      end
    end

  end
end