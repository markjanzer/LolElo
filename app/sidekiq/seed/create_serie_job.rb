class Seed::CreateSerieJob
  include Sidekiq::Job

  def perform(serie_id)
    ApplicationSeeder::CreateSerie.call(serie_id)
  end
end
