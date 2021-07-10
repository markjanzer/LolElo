class Serie
  class SetInitialElos
    def initialize(serie:, previous_serie:)
      @serie = serie
      @previous_serie = previous_serie
    end

    def call
      serie.teams.each do |team|
        if previous_serie && previous_serie.teams.include?(team)
          if previous_serie.year != serie.year
            Snapshot.create!(team: team, elo: revert(team.elo), date: first_of_year(serie.year))
          end
        else
          Snapshot.create!(team: team, elo: EloVariables::NEW_TEAM_ELO, date: serie.begin_at)
        end
      end
    end

    private

    attr_reader :serie, :previous_serie

    def revert(elo)
      elo - ((elo - EloVariables::RESET_ELO) * EloVariables::RATE_OF_REVERSION)
    end

    def first_of_year(year)
      Date.new(year, 1, 1)
    end
  end
end