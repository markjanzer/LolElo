class Seed::CreateSerieJob
  include Sidekiq::Job

  def perform(serie_id)
    PandaScore::Serie
      .find_or_initialize_by(panda_score_id: serie_id)
      .update_from_api
    
    ::Seed::EnqueueTournamentsCreationJob.perform_async(serie_id)
  end
end
