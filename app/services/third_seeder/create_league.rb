module ThirdSeeder
  class CreateLeague
    def initialize(league_id)
      @league_id = league_id
    end

    def self.call(*)
      new(*).call
    end

    def call(league_id)
      PandaScore::League.find_or_initialize_by(panda_score_id: league_id)
        .update(data: fetch_league_data)
  
      Seed::EnqueueSeriesCreationJob.perform_async(league_id)
    end
  
    private
  
    attr_reader :league_id
  
    def fetch_league_data
      PandaScore.league(id: league_id)
    end
  end
end