module ThirdSeeder
  class CreateSerie
    def initialize(serie_id)
      @serie_id = serie_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      PandaScore::Serie.find_or_initialize_by(panda_score_id: serie_id)
        .update(data: fetch_serie_data)

      Seed::EnqueueTournamentsCreationJob.perform_async(serie_id)
    end

    private

    attr_reader :serie_id

    def fetch_serie_data
      PandaScore.serie(id: serie_id)
    end
  end
end