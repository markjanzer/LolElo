module ThirdSeeder
  class EnqueueTournamentsCreation
    def initialize(serie_id)
      @serie_id = serie_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_tournaments.each do |tournament|
        ::Seed::CreateTournamentJob.perform_async(tournament["id"])
      end
    end

    private

    attr_reader :serie_id

    def fetch_tournaments
      PandaScore.tournaments(serie_id: serie_id)
    end
  end
end