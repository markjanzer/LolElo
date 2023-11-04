class Seed::CreateSerieJob
  include Sidekiq::Job

  def perform(serie_id)
    PandaScoreAPISeeder::CreateSerie.call(serie_id)
  end
end
