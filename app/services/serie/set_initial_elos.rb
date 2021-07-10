class Serie
  class SetInitialElos
    def initialize(serie)
      @serie = serie
    end

    def call
      serie.teams.each do |team|
        if !team_in_previous_serie(team)
          create_new_team_elo(team)
        elsif previous_serie_in_other_season
          create_reverted_elo(team)
        end
      end
    end

    private

    attr_reader :serie, :previous_serie

    def league
      serie.league
    end

    def previous_serie
      @previous_serie ||= league.series
        .where("begin_at < ?", serie.begin_at)
        .order(begin_at: :desc)
        .first
    end

    def team_in_previous_serie(team)
      previous_serie && previous_serie.teams.include?(team)
    end

    def previous_serie_in_other_season
      previous_serie && previous_serie.year != serie.year
    end

    def create_new_team_elo(team)
      Snapshot.create!(team: team, elo: EloVariables::NEW_TEAM_ELO, date: serie.begin_at)
    end

    def create_reverted_elo(team)
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