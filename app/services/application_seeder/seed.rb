module ApplicationSeeder
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
      leagues_seed_data.each do |data|
        ApplicationSeeder::CreateLeague.new(
          panda_score_id: data[:league_id],
          time_zone: data[:time_zone]
        ).call
      end
    end
    
    def create_all_series
      League.all.each do |league|
        ApplicationSeeder::CreateSeries.new(league.panda_score_id).call
      end
    end
    
    def create_all_tournaments
      Serie.all.each do |serie|
        ApplicationSeeder::CreateTournaments.new(serie).call
      end
    end
    
    def create_all_teams
      Tournament.all.each do |tournament|
        ApplicationSeeder::CreateTeams.new(tournament).call
      end
    end
    
    def create_all_matches
      Tournament.all.each do |tournament|
        ApplicationSeeder::CreateMatches.new(tournament).call
      end
    end
    
    def create_all_games
      Match.all.each do |match|
        ApplicationSeeder::CreateGames.new(match).call
      end
    end
  end
end