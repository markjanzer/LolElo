module ApplicationSeeder
  class Seed
    LEAGUE_SEED_DATA =  [
      { abbreviation: "lcs", league_id: 4198, time_zone: "America/Los_Angeles" },
      { abbreviation: "lec", league_id: 4197, time_zone: "Europe/Berlin" },
      { abbreviation: "lck", league_id: 293, time_zone: "Asia/Seoul" },
      { abbreviation: "lpl", league_id: 294, time_zone: "Asia/Shanghai" }
    ]

    def call
      create_leagues(LEAGUE_SEED_DATA)
      create_all_series(League.all)
      create_all_tournaments(Serie.all)
      create_all_teams(Tournament.all)
      create_all_matches(Tournament.all)
      create_all_games(Match.all)
      UpdateTracker.record_model_update
    end

    def reset
      Snapshot.destroy_all
      Game.destroy_all
      Match.destroy_all
      Team.destroy_all
      Tournament.destroy_all
      Serie.destroy_all
      League.destroy_all
      UpdateTracker.destroy_all
    end

    private
    
    attr_reader :leagues_seed_data

    def create_leagues(seed_data)
      seed_data.each do |data|
        ps_league = PandaScore::League.find_by(panda_score_id: data[:league_id])
        ModelUpsert::League.call(
          panda_score_league: ps_league,
          time_zone: data[:time_zone]
        )
      end
    end
    
    def create_all_series(leagues)
      leagues.each do |league|
        panda_score_league = league.panda_score_league
        panda_score_series = panda_score_league.panda_score_series
        panda_score_series.each do |ps_serie|
          ModelUpsert::Serie.call(ps_serie)
        end
      end
    end
    
    def create_all_tournaments(series)
      series.each do |serie|
        panda_score_serie = serie.panda_score_serie
        panda_score_tournaments = panda_score_serie.panda_score_tournaments
        panda_score_tournaments.each do |ps_tournament|
          ModelUpsert::Tournament.call(ps_tournament)
        end
      end
    end
    
    def create_all_teams(tournaments)
      tournaments.each do |tournament|
        panda_score_tournament = tournament.panda_score_tournament
        panda_score_teams = panda_score_tournament.panda_score_teams
        panda_score_teams.each do |ps_team|
          ModelUpsert::Team.call(ps_team: ps_team, tournament: tournament)
        end
      end
    end
    
    def create_all_matches(tournaments)
      tournaments.each do |tournament|
        panda_score_tournament = tournament.panda_score_tournament
        panda_score_matches = panda_score_tournament.panda_score_matches
        panda_score_matches.each do |ps_match|
          ModelUpsert::Match.call(ps_match)
        end
      end
    end
    
    def create_all_games(matches)
      matches.each do |match|
        panda_score_match = match.panda_score_match
        panda_score_games = panda_score_match.panda_score_games
        panda_score_games.each do |ps_game|
          ModelUpsert::Game.call(ps_game)
        end
      end
    end
  end
end