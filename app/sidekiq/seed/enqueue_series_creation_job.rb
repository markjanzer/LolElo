class Seed::EnqueueSeriesCreationJob
  include Sidekiq::Job

  def perform(league_id)
    fetched_series = PandaScoreAPI.series(league_id: league_id)
    serie_ids = fetched_series.map { |serie| [serie["id"]] }
    ::Seed::CreateSerieJob.perform_bulk(serie_ids)
  end
end
