module PandaScoreAPISeeder
  class Seed
    LEAGUE_SEED_DATA =  [
      { abbreviation: "lcs", league_id: 4198, time_zone: "America/Los_Angeles" },
      { abbreviation: "lec", league_id: 4197, time_zone: "Europe/Berlin" },
      { abbreviation: "lck", league_id: 293, time_zone: "Asia/Seoul" },
      { abbreviation: "lpl", league_id: 294, time_zone: "Asia/Shanghai" }
    ]

    def initialize(leagues_seed_data)
      @leagues_seed_data = leagues_seed_data
    end

    def call
      create_leagues
      create_all_series
      create_all_tournaments
      create_all_teams
      create_all_matches
      create_all_games
    end

    private

    attr_reader :leagues_seed_data

    def create_leagues
      League.transaction do
        leagues_seed_data.each do |league_seed_data|
          PandaScoreAPISeeder::CreateLeague.new(league_seed_data).call
        end
      end
    end
    
    def create_all_series
      Serie.transaction do
        League.all.each do |league|
          PandaScoreAPISeeder::CreateSeries.new(league).create_last
        end
      end
    end
    
    def create_all_tournaments
      Tournament.transaction do
        Serie.all.each do |serie|
          PandaScoreAPISeeder::CreateTournaments.new(serie).call
        end
      end
    end
    
    def create_all_teams
      Team.transaction do
        Tournament.all.each do |tournament|
          PandaScoreAPISeeder::CreateTeams.new(tournament).call
        end
      end
    end
    
    def create_all_matches
      Match.transaction do
        Tournament.all.each do |tournament|
          PandaScoreAPISeeder::CreateMatches.new(tournament).call
        end
      end
    end
    
    def create_all_games
      Game.transaction do
        Match.all.each do |match|
          PandaScoreAPISeeder::CreateGames.new(match).call
        end
      end
    end
  end
end