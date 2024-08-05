# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EloSnapshots::SerieTeamInitializer do
  describe "#call" do

    def setup
      league = create(:league)
      serie = create(:serie, league: league, begin_at: "2020-06-01", year: 2020)
      tournament = create(:tournament, serie: serie)
      team = create(:team)
      create(:teams_tournament, team: team, tournament: tournament)

      { 
        league: league, 
        serie: serie, 
        tournament: tournament, 
        team: team
      }
    end

    context "when the team has an elo from the current serie" do
      it "does nothing" do
        setup => { team:, serie: }
        create(:snapshot, team: team, serie: serie)
        expect { described_class.new(team: team, serie: serie).call }.not_to change { Snapshot.count }
      end
    end

    context "when the team has an elo from another serie in the same year" do
      it "does nothing" do
        setup => { team:, serie:, league: }

        other_serie = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)
        other_tournament = create(:tournament, serie: other_serie)
        create(:teams_tournament, team: team, tournament: other_tournament)
        create(:snapshot, team: team, serie: other_serie)

        expect { described_class.new(team: team, serie: serie).call }.not_to change { Snapshot.count }
      end
    end

    context "when the team no elo from the current year" do
      context "when the team has elo from the previous year" do
        it "creates a snapshot with reverted elo" do
          setup => { team:, serie:, league: }

          last_year_serie = create(:serie, league: league, begin_at: "2019-01-01", year: 2019)
          last_year_tournament = create(:tournament, serie: last_year_serie)
          create(:teams_tournament, team: team, tournament: last_year_tournament)
          last_year_snapshot = create(:snapshot, elo: 1200, team: team, serie: last_year_serie)

          reverted_elo = EloCalculator::Revert.new(last_year_snapshot.elo).call

          expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1

          snapshot = Snapshot.last
          expect(snapshot.elo).to eq(reverted_elo)
        end

        it "creates a snapshot with correct attributes" do
          setup => { team:, serie:, league: }

          old_serie = create(:serie, league: league, begin_at: "2019-01-01", year: 2019)
          old_tournament = create(:tournament, serie: old_serie)
          create(:teams_tournament, team: team, tournament: old_tournament)
          old_snapshot = create(:snapshot, elo: 1200, team: team, serie: old_serie)

          reverted_elo = EloCalculator::Revert.new(old_snapshot.elo).call

          described_class.new(team: team, serie: serie).call

          snapshot = Snapshot.last
          expect(snapshot).to have_attributes(
            team: team,
            serie: serie,
            elo_reset: true,
            datetime: serie.begin_at,
            elo: reverted_elo
          )          
        end

        context "there was an earlier serie in the current year" do
          it "creates a snapshot with reverted elo" do
            setup => { team:, serie:, league: }

            _pervious_serie_from_same_year = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)

            last_year_serie = create(:serie, league: league, begin_at: "2019-01-01", year: 2019)
            last_year_tournament = create(:tournament, serie: last_year_serie)
            create(:teams_tournament, team: team, tournament: last_year_tournament)
            last_year_snapshot = create(:snapshot, elo: 1200, team: team, serie: last_year_serie)

            reverted_elo = EloCalculator::Revert.new(last_year_snapshot.elo).call

            expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1

            snapshot = Snapshot.last
            expect(snapshot.elo).to eq(reverted_elo)
          end
        end
      end

      context "when the team does not have elo from the previous year" do
        it "creates a snapshot with new_team elo" do
          setup => { team:, serie: }

          expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1

          snapshot = Snapshot.last
          expect(snapshot.elo).to eq(EloCalculator::NEW_TEAM_ELO)
        end

        it "creates a snapshot with the correct attributes" do
          setup => { team:, serie: }

          described_class.new(team: team, serie: serie).call

          snapshot = Snapshot.last
          expect(snapshot).to have_attributes(
            team: team,
            serie: serie,
            elo_reset: true,
            datetime: serie.begin_at,
            elo: EloCalculator::NEW_TEAM_ELO
          )
        end

        context "there was an earlier serie in the current year" do
          it "creates a snapshot with new_team elo" do
            setup => { team:, serie:, league: }

            _pervious_serie_from_same_year = create(:serie, league: league, begin_at: "2020-01-01", year: 2020)

            expect { described_class.new(team: team, serie: serie).call }.to change { Snapshot.count }.by 1

            snapshot = Snapshot.last
            expect(snapshot.elo).to eq(EloCalculator::NEW_TEAM_ELO)
          end
        end
      end
    end
  end
end