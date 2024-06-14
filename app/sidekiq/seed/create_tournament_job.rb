class Seed::CreateTournamentJob
  include Sidekiq::Job

  def perform(tournament_id)
    PandaScore::Tournament.create_or_update_from_api(tournament_id)

    ::Seed::EnqueueTeamsCreationJob.perform_async(tournament_id)
    ::Seed::EnqueueMatchesCreationJob.perform_async(tournament_id)
  end
end
