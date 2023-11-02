class Seed::EnqueueSeriesCreationJob
  include Sidekiq::Job

  def perform(league_id)
    ThirdSeeder::EnqueueSeriesCreation.call(league_id)
  end
end
