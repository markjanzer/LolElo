module ThirdSeeder
  class EnqueueTournamentsCreation
    def initialize(serie_id)
      @serie_id = serie_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_tournaments(serie_id)
        .each do |tournament|
          Seed::CreateTournamentJob.perform_async(tournament["id"])
        end
    end

    private

    def fetch_tournaments(serie_id)
      PandaScore.tournaments(serie_id: serie_id)
    end
  end
end