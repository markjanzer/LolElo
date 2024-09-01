module Season
  class Statistics
    def initialize(year:, league_id:)
      @year = year
      @league = League.find(league_id)
      @series = Serie.where(league_id: league_id, year: year)
    end

    def call
      starting_elos, ending_elos, most_improved, most_declined = team_elo_changes
        .values_at(:starting_elos, :ending_elos, :most_improved, :most_declined)
      most_dominant, weakest = most_and_least_dominant

      return {
        starting_elos: starting_elos,
        ending_elos: ending_elos,
        most_dominant: most_dominant,
        weakest: weakest,
        most_improved: most_improved,
        steepest_decline: most_declined
      }
    end

    private

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
        #{SEASON_TEAMS_SQL};
      SQL

      season_team_ids = ActiveRecord::Base.connection
        .execute(season_teams_sql)
        .map { |r| r["id"] }
      Team.where(id: season_team_ids)
    end

    SEASON_START_AND_END_SQL = <<-SQL
      SELECT MIN(matches.end_at) AS season_start, MAX(matches.end_at) AS season_end
      FROM series
      join tournaments on tournaments.serie_id = series.id
      join matches on matches.tournament_id = tournaments.id
      JOIN season_series ON season_series.id = tournaments.serie_id
    SQL

    SEASON_TEAMS_SQL = <<-SQL
      SELECT DISTINCT teams.id
      FROM teams
      JOIN teams_tournaments ON teams_tournaments.team_id = teams.id
      JOIN tournaments ON tournaments.id = teams_tournaments.tournament_id
      JOIN season_series ON season_series.id = tournaments.serie_id
    SQL

    def season_start_and_end_dates
      sql = <<-SQL
        WITH season_series AS (#{season_series_sql})
        #{SEASON_START_AND_END_SQL};
      SQL
      
      dates = ActiveRecord::Base.connection.execute(sql)[0]
      [dates["season_start"], dates["season_end"]]
    end

    def team_elo_changes
      season_start, season_end = season_start_and_end_dates

      starting_elos = {
        date: season_start.strftime("%B %d, %Y"),
        teams: []
      }

      ending_elos = {
        date: season_end.strftime("%B %d, %Y"),
        teams: [] 
      }

      sql = <<-SQL
        WITH season_series AS (
          #{season_series_sql}
        ), season_teams AS (
          #{SEASON_TEAMS_SQL}
        ), season_start_and_end AS (
          #{SEASON_START_AND_END_SQL}
        ), pre_season_elo AS (
          SELECT DISTINCT ON (season_teams.id)
            season_teams.id AS team_id,
            snapshots.elo AS pre_season_elo
          FROM season_teams
          JOIN snapshots ON snapshots.team_id = season_teams.id
          CROSS JOIN season_start_and_end
          WHERE snapshots.datetime < season_start_and_end.season_start
          ORDER BY season_teams.id, snapshots.datetime DESC
        ), end_season_elo AS (
          SELECT DISTINCT ON (season_teams.id)
            season_teams.id AS team_id,
            snapshots.elo AS end_season_elo
          FROM season_teams
          JOIN snapshots ON snapshots.team_id = season_teams.id
          CROSS JOIN season_start_and_end
          WHERE snapshots.datetime <= season_start_and_end.season_end
          ORDER BY season_teams.id, snapshots.datetime DESC
        )
        SELECT
          season_teams.id AS team_id,
          pre_elo.pre_season_elo AS pre_season_elo,
          end_elo.end_season_elo AS end_season_elo,
          end_elo.end_season_elo - pre_elo.pre_season_elo AS elo_change
        FROM season_teams
        LEFT JOIN pre_season_elo pre_elo ON season_teams.id = pre_elo.team_id
        LEFT JOIN end_season_elo end_elo ON season_teams.id = end_elo.team_id;
      SQL

      team_elos = ActiveRecord::Base.connection.execute(sql)

      team_elos.each do |result|
        team = season_teams.find { |team| team.id == result["team_id"] }
        starting_elos[:teams] << { 
          name: team.name, 
          color: team.color, 
          elo: result["pre_season_elo"] 
        }
        ending_elos[:teams] << {
          name: team.name,
          color: team.color,
          elo: result["end_season_elo"]
        }
      end

      starting_elos[:teams] = starting_elos[:teams].sort_by { |team| -team[:elo] }
      ending_elos[:teams] = ending_elos[:teams].sort_by { |team| -team[:elo] }

      # Determine most and least improved teams
      sorted_team_elos = team_elos.to_a.sort_by! { |team| -team["elo_change"] }
      most_improved_team = season_teams.find { |team| team.id == sorted_team_elos.first["team_id"] }
      most_declined_team = season_teams.find { |team| team.id == sorted_team_elos.last["team_id"] }

      most_improved =  {
        name: most_improved_team.name,
        color: most_improved_team.color,
        elo_change: sorted_team_elos.first["elo_change"].abs
      }
      most_declined = {
        name: most_declined_team.name,
        color: most_declined_team.color,
        elo_change: sorted_team_elos.last["elo_change"].abs
      }

      return {
        starting_elos: starting_elos,
        ending_elos: ending_elos,
        most_improved: most_improved,
        most_declined: most_declined
      }
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
  end
end