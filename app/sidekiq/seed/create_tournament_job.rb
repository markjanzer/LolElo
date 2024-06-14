class Seed::CreateTournamentJob
  include Sidekiq::Job

  def perform(tournament_id)
    PandaScore::Tournament
      .find_or_initialize_by(panda_score_id: tournament_id)
      .update_from_api

    ::Seed::EnqueueTeamsCreationJob.perform_async(tournament_id)
    ::Seed::EnqueueMatchesCreationJob.perform_async(tournament_id)
  end
end
