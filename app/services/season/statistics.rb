module Season
  class Statistics
    def initialize(year:, league_id:)
      @year = year
      @league = League.find(league_id)
      @series = Serie.where(league_id: league_id, year: year)
    end

    def call
      starting_elos, ending_elos = starting_elos_and_ending_elos
      most_dominant, weakest = most_and_least_dominant

      return {
        starting_elos: starting_elos,
        ending_elos: ending_elos,
        most_dominant: most_dominant,
        weakest: weakest,
      }
    end

    private

    def season_start_and_end_dates
      sql = <<-SQL
        WITH season_series AS (#{season_series_sql})
        SELECT MIN(matches.end_at) AS season_start, MAX(matches.end_at) AS season_end
        FROM series
        join tournaments on tournaments.serie_id = series.id
        join matches on matches.tournament_id = tournaments.id
        JOIN season_series ON season_series.id = tournaments.serie_id
        ;
      SQL
      
      dates = ActiveRecord::Base.connection.execute(sql)[0]
      [dates["season_start"], dates["season_end"]]
    end

    def starting_elos_and_ending_elos
      season_start, season_end = season_start_and_end_dates
  
      starting_elos = {
        date: season_start.strftime("%B %d, %Y"),
        teams: season_teams.map do |team| 
          { 
            name: team.name,
            color: team.color,
            elo: team.elo_before(season_start) 
          }
        end.sort_by { |team| -team[:elo] }
      }
      ending_elos = {
        date: season_end.strftime("%B %d, %Y"),
        teams: season_teams.map do |team| 
          { 
            name: team.name,
            color: team.color,
            elo: team.elo_at(season_end) 
          }
        end.sort_by { |team| -team[:elo] }
      }

      return [starting_elos, ending_elos]
    end

    def most_and_least_dominant
      most_dominant_team_id, most_dominant_team_average_elo = average_elos.first.values_at("id", "average_elo")
      most_dominant_team = season_teams.find { |team| team.id == most_dominant_team_id }
      most_dominant = { name: most_dominant_team.name, color: most_dominant_team.color, average_elo: most_dominant_team_average_elo.round }

      worst_team_id, worst_team_average_elo = average_elos.last.values_at("id", "average_elo")
      worst_team = season_teams.find { |team| team.id == worst_team_id }
      least_dominant = { name: worst_team.name, color: worst_team.color, average_elo: worst_team_average_elo.round }

      return [most_dominant, least_dominant]
    end

    def season_teams
      season_teams_sql = <<-SQL
        WITH season_series AS (#{season_series_sql})
        SELECT DISTINCT teams.id
        FROM teams
        JOIN teams_tournaments ON teams_tournaments.team_id = teams.id
        JOIN tournaments ON tournaments.id = teams_tournaments.tournament_id
        JOIN season_series ON season_series.id = tournaments.serie_id
      SQL

      season_team_ids = ActiveRecord::Base.connection.execute(season_teams_sql)
      Team.where(id: season_team_ids)
    end

    def average_elos
      average_elo_sql = <<-SQL
        WITH season_series AS (#{season_series_sql})
        SELECT teams.id, avg(snapshots.elo) AS average_elo
        FROM snapshots
        JOIN teams ON snapshots.team_id = teams.id
        JOIN games ON snapshots.game_id = games.id
        JOIN matches ON games.match_id = matches.id
        JOIN tournaments ON matches.tournament_id = tournaments.id
        JOIN season_series ON tournaments.serie_id = season_series.id
        GROUP BY teams.id
        ORDER BY avg(snapshots.elo) DESC;
      SQL
      
      ActiveRecord::Base.connection
        .execute(average_elo_sql)
        .to_a
    end

    def season_series_sql
      <<-SQL
        SELECT series.id
        FROM series
        WHERE series.league_id = #{@league.id}
        AND series.year = #{@year}
      SQL
    end

    def season_teams
      season_teams_sql = <<-SQL
        WITH season_series AS (#{season_series_sql})
        SELECT DISTINCT teams.id
        FROM teams
        JOIN teams_tournaments ON teams_tournaments.team_id = teams.id
        JOIN tournaments ON tournaments.id = teams_tournaments.tournament_id
        JOIN season_series ON season_series.id = tournaments.serie_id
      SQL

      season_team_ids = ActiveRecord::Base.connection
        .execute(season_teams_sql)
        .map { |r| r["id"] }
      Team.where(id: season_team_ids)
    end
  end
end