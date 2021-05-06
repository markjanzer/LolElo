# frozen_string_literal: true

lcs = LeagueFactory.new(league_id: 4198, time_zone: 'America/Los_Angeles').call
lec = LeagueFactory.new(league_id: 4197, time_zone: 'Europe/Berlin').call
# lck = LeagueFactory.new(league_id: 293, time_zone: "Asia/Seoul").call
# lpl = LeagueFactory.new(league_id: 294, time_zone: "Asia/Shanghai" ).call

Snapshot.transaction do
  League.all.each do |league|
    SnapshotFactory.new(league).call
  end
end

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
create_matches
create_games
create_snapshots

# Create Leagues
def create_leagues
  League.transaction do
    leagues_seed_data.each do |league_seed_data|
      league_data = PandaScoreAPI.league(id: league_seed_data[:league_id])
      league = LeagueFactory.new(league_data: league_data, time_zone: league_seed_data[:time_zone]).call
      league.save!
    end
  end
end

def create_series
  Serie.transaction do
    League.each do |league|
      series_data = PandaScoreAPI.series(league_id: league.pandascore_id)
      series_data.each do |serie_data|
        serie = SerieFactory.new(serie_data)
        league.series << serie
      end
    end
  end
end

