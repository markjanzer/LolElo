class Seed::CreateSerieJob
  include Sidekiq::Job

  def perform(serie_id)
    ThirdSeeder::CreateSerie.call(serie_id)
  end
end
