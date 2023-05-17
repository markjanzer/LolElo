class Seeder
  class SeedFromPandaScore
    
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