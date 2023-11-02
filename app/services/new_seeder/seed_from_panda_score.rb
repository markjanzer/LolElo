
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

    # This method is meant to be called multiple times and to only move on to the next stage when
    # The previous set of objects have been created and populated with data
    def call
      if PandaScore::League.count.zero?
        return NewSeeder::CreateLeagues.call(LEAGUE_IDS)
      end

      if PandaScore::League.where(data: {}).count = 0 && PandaScore::Serie.count.zero?
        return NewSeeder::CreateSeries.call
      end

      if PandaScore::Serie.where(data: {}).count.zero? && PandaScore::Tournament.count.zero?
        return NewSeeder::CreateTournaments.call
      end

      if PandaScore::Tournament.where(data: {}).count.zero? && PandaScore::Team.count.zero?
        return NewSeeder::CreateTeams.call
      end

      if PandaScore::Team.where(data: {}).count.zero? && PandaScore::Match.count.zero?
        return NewSeeder::CreateMatches.call
      end

      if PandaScore::Match.where(data: {}).count.zero? && PandaScore::Game.count.zero?
        return NewSeeder::CreateGames.call
      end

      "Done!"
    end
  end
end