WITH season_series AS (
  SELECT series.id
  FROM series
  WHERE series.league_id = 14
  AND series.year = 2024
), games_with_teams AS (
  SELECT 
    games.id AS game_id,
    games.end_at AS game_time,
    matches.opponent1_id AS team1_id,
    matches.opponent2_id AS team2_id,
    games.winner_id,
    tournaments.serie_id
  FROM games
  JOIN matches ON games.match_id = matches.id
  JOIN tournaments ON matches.tournament_id = tournaments.id
  JOIN season_series ON tournaments.serie_id = season_series.id
), pre_game_elo_ratings AS (
  SELECT 
    snapshots.team_id,
    snapshots.game_id,
    snapshots.elo,
    ROW_NUMBER() OVER (
      PARTITION BY snapshots.team_id, games_with_teams.game_id 
      ORDER BY snapshots.datetime DESC
    ) AS row_number
  FROM snapshots
  JOIN games_with_teams ON snapshots.team_id IN (games_with_teams.team1_id, games_with_teams.team2_id)
  WHERE snapshots.datetime < games_with_teams.game_time
)
SELECT 
  games_with_teams.game_id,
  games_with_teams.game_time,
  games_with_teams.team1_id,
  team1.name AS team1_name,
  team1_elo.elo AS team1_pre_game_elo,
  games_with_teams.team2_id,
  team2.name AS team2_name,
  team2_elo.elo AS team2_pre_game_elo,
  games_with_teams.winner_id,
  CASE 
    WHEN games_with_teams.winner_id = games_with_teams.team1_id THEN 400 + team2_elo.elo
    WHEN games_with_teams.winner_id = games_with_teams.team2_id THEN 400 + team1_elo.elo
    ELSE (team1_elo.elo + team2_elo.elo) / 2  -- In case of a draw or unknown winner
  END AS performance_rating
FROM games_with_teams
LEFT JOIN pre_game_elo_ratings AS team1_elo 
  ON games_with_teams.team1_id = team1_elo.team_id 
  AND games_with_teams.game_id = team1_elo.game_id 
  AND team1_elo.row_number = 1
LEFT JOIN pre_game_elo_ratings AS team2_elo 
  ON games_with_teams.team2_id = team2_elo.team_id 
  AND games_with_teams.game_id = team2_elo.game_id 
  AND team2_elo.row_number = 1
JOIN teams AS team1 ON games_with_teams.team1_id = team1.id
JOIN teams AS team2 ON games_with_teams.team2_id = team2.id
ORDER BY games_with_teams.game_time;