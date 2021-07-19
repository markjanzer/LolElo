class Seeder
  class CreateLeague
    def initialize(league_seed_data)
      @league_seed_data = league_seed_data
    end

    def call
      new_league.save!
    end

    private

    attr_reader :league_seed_data

    def league_panda_score_data
      @league_panda_score_data ||= PandaScore.league(id: league_seed_data[:league_id])
    end

    def new_league
      LeagueFactory.new(league_data: league_panda_score_data, time_zone: league_seed_data[:time_zone]).call
    end
  end
end