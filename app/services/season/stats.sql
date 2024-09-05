-- Get the beginning and ending elo for each match

WITH season_series AS (
    SELECT series.id
    FROM series
    WHERE series.league_id = 14
      AND series.year = 2024
)
SELECT matches.id
FROM matches
JOIN tournaments ON matches.tournament_id = tournaments.id
JOIN season_series ON tournaments.serie_id = season_series.id
JOIN games ON matches.id = games.match_id
JOIN snapshots ON snapshots.game_id = games.id
GROUP BY matches.id
HAVING COUNT(games.id) > 1