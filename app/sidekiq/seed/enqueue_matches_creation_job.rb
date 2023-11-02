class Seed::EnqueueMatchesCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    ThirdSeeder::EnqueueMatchesCreation.call(tournament_id)
  end
end