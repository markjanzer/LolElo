module EloSnapshots
  class SerieTeamInitializer
    def initialize(team:, serie:)
      @serie = serie
      @team = team
    end

    def call
      # If there is a snapshot for this team in the serie's season, do nothing
      return if team.snapshots.where(serie: same_year_series).present?

      # If there is a snapshot for this team in the previous season, revert the elo
      return create_reverted_elo if team.snapshots.where(serie: previous_year_series).present?

      # If there is no snapshot for this team in either, then set a new elo
      create_new_team_elo
    end

    private

    attr_reader :team, :serie

    delegate :league, to: :serie

    def same_year_series
      league.series.where(year: serie.year)
    end

    def previous_year_series
      league.series.where(year: serie.year - 1)
    end

    def create_new_team_elo
      Snapshot.create!(team: team, elo: EloCalculator::NEW_TEAM_ELO, datetime: serie.begin_at, serie: serie, elo_reset: true)
    end

    def create_reverted_elo
      Snapshot.create!(team: team, elo: reverted_elo, datetime: serie.begin_at, serie: serie, elo_reset: true)
    end

    def reverted_elo
      EloCalculator::Revert.new(team.elo).call
    end
  end
end