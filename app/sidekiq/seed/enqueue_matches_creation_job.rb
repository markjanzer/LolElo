class Seed::EnqueueMatchesCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    ApplicationSeeder::EnqueueMatchesCreation.call(tournament_id)
  end
end