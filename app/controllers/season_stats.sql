select min(matches.end_at), max(matches.end_at)
from series
join tournaments on tournaments.serie_id = series.id
join matches on matches.tournament_id = tournaments.id
where series.league_id = 14
and series.year = 2024
;

select teams.*
from teams
join teams_tournaments on teams_tournaments.team_id = teams.id
join tournaments on tournaments.id = teams_tournaments.tournament_id
join series on tournaments.serie_id = series.id and series.league_id = 14 and series.year = 2024
group by teams.id
;

select teams.id, teams.name, teams.color, snapshots.elo, snapshots.datetime
from snapshots
join teams on snapshots.team_id = teams.id
join games on snapshots.game_id = games.id
join matches on games.match_id = matches.id
join tournaments on matches.tournament_id = tournaments.id
join series on tournaments.serie_id = series.id
where series.league_id = 14
and series.year = 2024
;

with season_series as (
  select series.id
  from series
  where series.league_id = 14
  and series.year = 2024
), season_teams as (
  select teams.*
  from teams
  join teams_tournaments on teams_tournaments.team_id = teams.id
  join tournaments on tournaments.id = teams_tournaments.tournament_id
  join series on tournaments.serie_id = series.id
  join season_series on season_series.id = series.id
  group by teams.id
), season_snapshots as (
  select snapshots.*
  from snapshots
  join teams on snapshots.team_id = teams.id
  join games on snapshots.game_id = games.id
  join matches on games.match_id = matches.id
  join tournaments on matches.tournament_id = tournaments.id
  join series on tournaments.serie_id = series.id
  join season_series on season_series.id = series.id
)


WITH season_series AS (
  SELECT series.id
  FROM series
  WHERE series.league_id = 14
  AND series.year = 2024
), season_teams AS (
  SELECT DISTINCT teams.*
  FROM teams
  JOIN teams_tournaments ON teams_tournaments.team_id = teams.id
  JOIN tournaments ON tournaments.id = teams_tournaments.tournament_id
  JOIN season_series ON season_series.id = tournaments.serie_id
), season_start_and_end AS (
  SELECT MIN(matches.end_at) AS season_start, MAX(matches.end_at) AS season_end
  FROM series
  JOIN tournaments ON tournaments.serie_id = series.id
  JOIN matches ON matches.tournament_id = tournaments.id
  JOIN season_series ON season_series.id = series.id
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
  st.id AS team_id,
  st.name AS team_name,
  pre_elo.pre_season_elo AS pre_season_elo,
  end_elo.end_season_elo AS end_season_elo,
  end_elo.end_season_elo - pre_elo.pre_season_elo AS elo_change
FROM season_teams st
LEFT JOIN pre_season_elo pre_elo ON st.id = pre_elo.team_id
LEFT JOIN end_season_elo end_elo ON st.id = end_elo.team_id
ORDER BY st.name;