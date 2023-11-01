
# Schema structure:
# Leagues > Series > Tournaments > Matches > Games


module NewSeeder
  class SeedFromPandaScore
    # SEED_DATA = leagues_seed_data = [
    #   { abbreviation: "lcs", league_id: 4198, time_zone: "America/Los_Angeles" },
    # ]
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
      create_series
      create_tournaments
      create_teams
      create_matches
      create_games
    end

    private

    def create_leagues
      LEAGUE_IDS.each do |league_id|
        league_data = PandaScore.league(id: league_id)
        PandaScore::League.find_or_initialize_by(panda_score_id: league_id)
          .update(data: league_data)
      end
    end

    def create_series
      PandaScore::League.all.each do |league|
        PandaScore.series(league_id: league.panda_score_id)
          .filter { |serie| include_serie?(serie["name"]) }
          .each do |serie|
            serie_data = PandaScore.serie(id: serie["id"])
            PandaScore::Serie.find_or_initialize_by(panda_score_id: serie["id"])
              .update(data: serie_data)
          end
      end
    end

    def create_tournaments
      PandaScore::Serie.all.each do |serie|
        PandaScore.tournaments(serie_id: serie.panda_score_id).each do |tournament|
          tournament_data = PandaScore.tournament(id: tournament["id"])
          PandaScore::Tournament.find_or_initialize_by(panda_score_id: tournament["id"])
            .update(data: tournament_data)
        end
      end
    end

    def create_teams
      PandaScore::Tournament.all.each do |tournament|
        PandaScore.teams(tournament_id: tournament.panda_score_id).each do |team|
          team_data = PandaScore.team(id: team["id"])
          PandaScore::Team.find_or_initialize_by(panda_score_id: team_data["id"])
            .update(data: team_data)
        end
      end
    end

    def create_matches
      PandaScore::Tournament.all.each do |tournament|
        PandaScore.matches(tournament_id: tournament.panda_score_id).each do |match|
          match_data = PandaScore.match(id: match["id"])
          PandaScore::Match.find_or_initialize_by(panda_score_id: match_data["id"])
            .update(data: match_data)
        end
      end
    end

    def create_games
      PandaScore::Match.all.each do |match|
        PandaScore.games(match_id: match.panda_score_id).each do |game|
          game_data = PandaScore.game(id: game["id"])
          PandaScore::Game.find_or_initialize_by(panda_score_id: game_data["id"])
            .update(data: game_data)
        end
      end
    end

    def include_serie?(name)
      name.split.first.match?('Spring|Summer')
    end
  end
end