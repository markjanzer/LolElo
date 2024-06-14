class Seed::CreateSerieJob
  include Sidekiq::Job

  def perform(serie_id)
    PandaScore::Serie.create_or_update_from_api(serie_id)

    ::Seed::EnqueueTournamentsCreationJob.perform_async(serie_id)
  end
end
