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
        tournament = TournamentFactory.new(tournament_data)
        serie.tournaments << tournament
      end
    end
  end
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
      games_data.each do |game_data|
        game = GameFactory.new(game_data)
        match.games << game
      end
    end
  end
end

def create_snapshots
  League.all.each do |league|
    # Probably not like this
    SnapshotFactory.new(league).call
  end
end
