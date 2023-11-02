module ThirdSeeder
  class CreateMatch
    def initialize(match_id)
      @match_id = match_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      PandaScore::Match.find_or_initialize_by(panda_score_id: match_id)
        .update(data: fetch_match_data)

      Seed::EnqueueGamesCreationJob.perform_async(match_id)
    end

    private

    attr_reader :match_id

    def fetch_match_data
      PandaScore.match(id: match_id)
    end
  end
end