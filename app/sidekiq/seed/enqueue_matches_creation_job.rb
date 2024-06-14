class Seed::EnqueueMatchesCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    fetched_matches = PandaScoreAPI.matches(tournament_id: tournament_id)
    match_ids = fetched_matches.map { |match| [match["id"]] }
    ::Seed::CreateMatchAndGamesJob.perform_bulk(match_ids)
  end
end