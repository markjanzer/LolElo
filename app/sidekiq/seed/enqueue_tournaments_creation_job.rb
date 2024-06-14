class Seed::EnqueueTournamentsCreationJob
  include Sidekiq::Job

  def perform(serie_id)
    fetched_tournaments = PandaScoreAPI.tournaments(serie_id: serie_id)
    tournament_ids = fetched_tournaments.map { |tournament| [tournament["id"]] }
    ::Seed::CreateTournamentJob.perform_bulk(tournament_ids)
  end
end
