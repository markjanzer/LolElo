class Seed::EnqueueSeriesCreationJob
  include Sidekiq::Job

  def perform(league_id)
    PandaScoreAPISeeder::EnqueueSeriesCreation.call(league_id)
  end
end
