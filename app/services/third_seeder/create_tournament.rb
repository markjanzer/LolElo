module ThirdSeeder
  class CreateTournament
    def initialize(tournament_id)
      @tournament_id = tournament_id
    end

    def self.call(*)
      new(*).call
    end

    def call(tournament_id)
      PandaScore::Tournament.find_or_initialize_by(panda_score_id: tournament_id)
        .update(data: fetch_tournament_data)
  
      Seed::CreateSeriesJob.perform_async(tournament_id)
    end
  
    private
  
    attr_reader :tournament_id
  
    def fetch_tournament_data
      PandaScore.tournament(id: tournament_id)
    end
  end
end