class Team
  class SetInitialSerieElo
    def initialize(team:, serie:)
      @serie = serie
      @team = team
    end

    def call
      return if team.snapshots.where("date >= ?", serie.begin_at).present?

      if !previous_serie || !team_in_previous_serie
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
      Snapshot.create!(team: team, elo: EloCalculator::NEW_TEAM_ELO, date: serie.begin_at, serie: serie, elo_reset: true)
    end

    def create_reverted_elo
      Snapshot.create!(team: team, elo: reverted_elo, date: serie.begin_at, serie: serie, elo_reset: true)
    end

    def reverted_elo
      EloCalculator::Revert.new(team.elo).call
    end
  end
end