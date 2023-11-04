module PandaScoreAPISeeder
  class CreateTournament
    def initialize(tournament_id)
      @tournament_id = tournament_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      PandaScore::Tournament.find_or_initialize_by(panda_score_id: tournament_id)
        .update(data: fetch_tournament_data)
  
      ::Seed::EnqueueTeamsCreationJob.perform_async(tournament_id)
      ::Seed::EnqueueMatchesCreationJob.perform_async(tournament_id)
    end
  
    private
  
    attr_reader :tournament_id
  
    def fetch_tournament_data
      PandaScoreAPI.tournament(id: tournament_id)
    end
  end
end