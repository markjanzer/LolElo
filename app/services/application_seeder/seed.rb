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
        ApplicationSeeder::CreateOrUpdateLeague.new(
          panda_score_id: data[:league_id],
          time_zone: data[:time_zone]
        ).call
      end
    end
    
    def create_all_series
      League.all.each do |league|
        panda_score_league = league.panda_score_league
        panda_score_series = panda_score_league.panda_score_series
        panda_score_series.each do |ps_serie|
          ApplicationSeeder::CreateOrUpdateSerie.new(ps_serie).call
        end
      end
    end
    
    def create_all_tournaments
      Serie.all.each do |serie|
        panda_score_serie = serie.panda_score_serie
        panda_score_tournaments = panda_score_serie.panda_score_tournaments
        panda_score_tournaments.each do |ps_tournament|
          ApplicationSeeder::CreateOrUpdateTournamnet.new(ps_tournament).call
        end
      end
    end
    
    def create_all_teams
      Tournament.all.each do |tournament|
        panda_score_tournament = tournament.panda_score_tournament
        panda_score_teams = panda_score_tournament.panda_score_teams
        panda_score_teams.each do |ps_team|
          ApplicationSeeder::CreateOrUpdateTeam.new(ps_team).call
        end
      end
    end
    
    def create_all_matches
      Tournament.all.each do |tournament|
        panda_score_tournament = tournament.panda_score_tournament
        panda_score_matches = panda_score_tournament.panda_score_matches
        panda_score_matches.each do |ps_match|
          ApplicationSeeder::CreateOrUpdateMatch.new(ps_match).call
        endl
      end
    end
    
    def create_all_games
      Match.all.each do |match|
        panda_score_match = match.panda_score_match
        panda_score_games = panda_score_match.panda_score_games
        panda_score_games.each do |ps_game|
          ApplicationSeeder::CreateOrUpdateGame.new(match).call
        end
      end
    end
  end
end