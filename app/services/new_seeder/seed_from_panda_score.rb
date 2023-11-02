
# Schema structure:
# Leagues > Series > Tournaments > Matches > Games


module NewSeeder
  class SeedFromPandaScore
    # SEED_DATA = [
    #   { abbreviation: "lcs", league_id: 4198, time_zone: "America/Los_Angeles" },
    #   { abbreviation: "lec", league_id: 4197, time_zone: "Europe/Berlin" },
    #   { abbreviation: "lck", league_id: 293, time_zone: "Asia/Seoul" },
    #   { abbreviation: "lpl", league_id: 294, time_zone: "Asia/Shanghai" }
    # ]

    LEAGUE_IDS = [
      4198, # LCS 
      4197, # LEC
      293,  # LCK
      294   # LPL
    ]

    def call
      NewSeeder::CreateLeagues.call(LEAGUE_IDS)
      NewSeeder::CreateSeries.call
      NewSeeder::CreateTournaments.call
      NewSeeder::CreateTeams.call
      NewSeeder::CreateMatches.call
      NewSeeder::CreateGames.call
    end
  end
end