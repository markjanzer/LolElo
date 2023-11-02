class Seed::EnqueueGamesCreationJob
  include Sidekiq::Job

  def perform(match_id)
    ThirdSeeder::EnqueueGamesCreation.call(match_id)
  end
end