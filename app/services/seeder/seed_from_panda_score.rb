class Seeder
  class SeedFromPandaScore

    UNIQUE_COLORS = ['#e6194B', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45', '#fabed4', '#469990', '#dcbeff', '#9A6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#a9a9a9', '#000000'].freeze
    
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
          Seeder::CreateLeague.new(league_seed_data).call
        end
      end
    end
    
    def create_all_series
      Serie.transaction do
        League.all.each do |league|
          Seeder::CreateSeries.new(league).call
        end
      end
    end
    
    def create_all_tournaments
      Tournament.transaction do
        Serie.all.each do |serie|
          create_tournaments(serie)
        end
      end
    end

    def create_tournaments(serie)
      tournaments_data = PandaScore.tournaments(serie_id: serie.external_id)
      tournaments_data.each do |tournament_data|
        tournament = TournamentFactory.new(tournament_data).call
        serie.tournaments << tournament
      end
    end
    
    def create_all_teams
      Team.transaction do
        Tournament.all.each do |tournament|
          teams_data = PandaScore.teams(tournament_id: tournament.external_id)
          teams_data.each do |team_data|
            color = unique_team_color(tournament.serie)
            team = TeamFactory.new(team_data: team_data, color: color).call
            unless tournament.teams.include?(team)
              tournament.teams << team
            end
          end
        end
      end
    end
    
    def unique_team_color(serie)
      (UNIQUE_COLORS - serie.teams.pluck(:color)).sample
    end
    
    def create_all_matches
      Match.transaction do
        Tournament.all.each do |tournament|
          matches_data = PandaScore.matches(tournament_id: tournament.external_id)
          matches_data.each do |match_data|
            match = MatchFactory.new(match_data).call
            tournament.matches << match
          end
        end
      end
    end
    
    def create_all_games
      Game.transaction do
        Match.all.each do |match|
          games_data = PandaScore.games(match_id: match.external_id)
          completed_games_data = games_data.reject { |game| game['forfeit'] }
          completed_games_data.each do |game_data|
            game = GameFactory.new(game_data).call
            match.games << game
          end
        end
      end
    end
  end
end