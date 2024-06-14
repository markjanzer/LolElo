class Seed::CreateLeagueJob
  include Sidekiq::Job

  def perform(league_id)
    PandaScore::League
      .find_or_initialize_by(panda_score_id: league_id)
      .update_from_api

    ::Seed::EnqueueSeriesCreationJob.perform_async(league_id)
  end
end
