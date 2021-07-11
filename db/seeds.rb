# frozen_string_literal: true

# set League data
leagues_seed_data = [
  { abbreviation: "lcs", league_id: 4198, time_zone: 'America/Los_Angeles' },
  { abbreviation: "lec", league_id: 4197, time_zone: 'Europe/Berlin' },
  { abbreviation: "lck", league_id: 293, time_zone: "Asia/Seoul" },
  { abbreviation: "lpl", league_id: 294, time_zone: "Asia/Shanghai" },
]

create_leagues(leagues_seed_data)
create_series
create_tournaments
create_teams
create_matches
create_games
create_snapshots

# Create Leagues
def create_leagues
  League.transaction do
    leagues_seed_data.each do |league_seed_data|
      league_data = PandaScore.league(id: league_seed_data[:league_id])
      league = LeagueFactory.new(league_data: league_data, time_zone: league_seed_data[:time_zone]).call
      league.save!
    end
  end
end

def create_series
  Serie.transaction do
    League.each do |league|
      series_data = PandaScore.series(league_id: league.pandascore_id)
      valid_series_data = series_data.select { |serie_data| valid_serie(serie_data) }
      valid_series_data.each do |serie_data|
        serie = SerieFactory.new(serie_data)
        league.series << serie
      end
    end
  end
end

def valid_serie(serie_data)
  serie_data['full_name'].split.first.match?('Spring|Summer')
end

def create_tournaments
  Tournament.transaction do
    Serie.each do |serie|
      tournaments_data = PandaScore.tournaments(serie_id: serie.pandascore_id)
      tournaments_data.each do |tournament_data|
        tournament = TournamentFactory.new(tournament_data: tournament_data)
        serie.tournaments << tournament
      end
    end
  end
end

def create_teams
  Team.transaction do
    Tournament.each do |tournament|
      teams_data = PandaScore.teams(tournament_id: tournament.pandascore_id)
      teams_data.each do |team_data|
        color = unique_team_color(tournament.serie)
        team = TeamFactory.new(team_data: team_data, color: color)
        unless tournament.teams.include?(team)
          tournament.teams << team
        end
      end
    end
  end
end

def create_team(team_data)
  team = Team.find_or_create_by(name: team_data['name'], external_id: team_data['id'], acronym: team_data['acronym'])
  team.tournaments << tournament
  team.update!(color: unique_team_color) if team.color.nil?
end

def unique_team_color(serie)
  (unique_colors - serie.teams.pluck(:color)).sample
end

def unique_colors
  ['#e6194B', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45', '#fabed4',
    '#469990', '#dcbeff', '#9A6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#a9a9a9', '#000000']
end

def create_matches
  Match.transaction do
    Tournament.each do |tournament|
      matches_data = PandaScore.matches(tournament_id: tournament.pandascore_id)
      matches_data.each do |match_data|
        match = MatchFactory.new(match_data)
        tournament.matches << match
      end
    end
  end
end

def create_games
  Game.transaction do
    Match.each do |match|
      games_data = PandaScore.games(match_id: match.pandascore_id)
      completed_games_data = games_data.reject { |game| game['forfeit'] }
      completed_games_data.each do |game_data|
        game = GameFactory.new(game_data)
        match.games << game
      end
    end
  end
end

def create_snapshots
  League.all.each do |league|
    League::CreateSnapshots.new(league).call
  end
end
