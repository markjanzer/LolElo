class Team
  class SetInitialSerieElo
    def initialize(team:, serie:)
      @serie = serie
      @team = team
    end

    def call
      # If there is a snapshot for this team in the serie's season, do nothing
      # If there is a snapshot for this team in the previous season, reset the elo
      # If there is no snapshot for this team in either, then set a new elo



      # If the team has an elo from a previous serie this year, do nothing
      # league = serie.league
      # series_in_this_year = league.series.where(year: serie.year)
      # puts series_in_this_year
      # puts team.snapshots.where(serie: series_in_this_year)
      # return if team.snapshots.where(serie: series_in_this_year).present?
      
      # This doesn't create a snapshot if any snapshot has been created since the series
      # begin_at. I don't like this because it enforces a chronological order of operations
      # Oh I guess that chronological is necessary to some extent though.
      return if team.snapshots.where("datetime >= ?", serie.begin_at).present?

      # This is not the logic I want
      # For instance, if a team did not participate in the 2021 Championship serie,
      # then they would get a new_team elo at the beginning of of 2022 because they
      # were not in the previous serie.
      if !previous_serie || !team_in_previous_serie
        create_new_team_elo
      elsif previous_serie_in_other_season
        create_reverted_elo
      end 
    end

    private

    attr_reader :team, :serie, :previous_serie

    delegate :league, to: :serie

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