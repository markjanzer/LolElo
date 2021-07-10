class Team
  class SetInitialEloForSerie
    def initialize(team:, serie:)
      @serie = serie
      @team = team
    end

    def call
      if !team_in_previous_serie
        create_new_team_elo
      elsif previous_serie_in_other_season
        create_reverted_elo
      end
    end

    private

    attr_reader :team, :serie, :previous_serie

    def league
      serie.league
    end

    def previous_serie
      @previous_serie ||= league.series
        .where("begin_at < ?", serie.begin_at)
        .order(begin_at: :desc)
        .first
    end

    def team_in_previous_serie
      previous_serie && previous_serie.teams.include?(team)
    end

    def previous_serie_in_other_season
      previous_serie && previous_serie.year != serie.year
    end

    def create_new_team_elo
      Snapshot.create!(team: team, elo: EloVariables::NEW_TEAM_ELO, date: serie.begin_at)
    end

    def create_reverted_elo
      Snapshot.create!(team: team, elo: revert(team.elo), date: first_of_year(serie.year))
    end

    def revert(elo)
      elo - ((elo - EloVariables::RESET_ELO) * EloVariables::RATE_OF_REVERSION)
    end

    def first_of_year(year)
      Date.new(year, 1, 1)
    end
  end
end