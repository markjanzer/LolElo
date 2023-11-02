class Seed::EnqueueMatchesCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    ThirdSeeder::EnqueuematchesCreation.call(tournament_id)
  end
end