module PandaScoreAPISeeder
  class EnqueueTournamentsCreation
    def initialize(serie_id)
      @serie_id = serie_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      tournament_ids = fetch_tournaments.map { |tournament| [tournament["id"]] }
      ::Seed::CreateTournamentJob.perform_bulk(tournament_ids)
    end

    private

    attr_reader :serie_id

    def fetch_tournaments
      PandaScoreAPI.tournaments(serie_id: serie_id)
    end
  end
end