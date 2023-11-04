class Seed::EnqueueSeriesCreationJob
  include Sidekiq::Job

  def perform(league_id)
    ApplicationSeeder::EnqueueSeriesCreation.call(league_id)
  end
end
