class NewSeeder
  class SeedFromPandaScore
    SEED_DATA = leagues_seed_data = [
      { abbreviation: "lcs", league_id: 4198, time_zone: "America/Los_Angeles" },
    ]
    # { abbreviation: "lec", league_id: 4197, time_zone: "Europe/Berlin" },
    # { abbreviation: "lck", league_id: 293, time_zone: "Asia/Seoul" },
    # { abbreviation: "lpl", league_id: 294, time_zone: "Asia/Shanghai" },

    LEAGUE_IDS = [
      4198, # LCS 
      4197, # LEC
      293,  # LCK
      294   # LPL
    ]

    def call
      create_leagues
      create_all_series
      create_all_tournaments
      create_all_teams
      create_all_matches
      create_all_games
    end

    private

    def create_leagues
      League.transaction do
        LEAGUE_IDS.each do |league_id|
          NewSeeder::CreateLeague.new(league_id).call
        end
      end
    end
    
    def create_all_series
      Serie.transaction do
        League.all.each do |league|
          Seeder::CreateSeries.new(league).create_last
        end
      end
    end
    
    def create_all_tournaments
      Tournament.transaction do
        Serie.all.each do |serie|
          Seeder::CreateTournaments.new(serie).call
        end
      end
    end
    
    def create_all_teams
      Team.transaction do
        Tournament.all.each do |tournament|
          Seeder::CreateTeams.new(tournament).call
        end
      end
    end
    
    def create_all_matches
      Match.transaction do
        Tournament.all.each do |tournament|
          Seeder::CreateMatches.new(tournament).call
        end
      end
    end
    
    def create_all_games
      Game.transaction do
        Match.all.each do |match|
          Seeder::CreateGames.new(match).call
        end
      end
    end
  end
end