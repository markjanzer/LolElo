class Seed::CreateLeagueJob
  include Sidekiq::Job

  def perform(league_id)
    PandaScore::League.create_or_update_from_api(league_id)

    ::Seed::EnqueueSeriesCreationJob.perform_async(league_id)
  end
end
