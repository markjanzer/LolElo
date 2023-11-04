class Seed::EnqueueMatchesCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    PandaScoreAPISeeder::EnqueueMatchesCreation.call(tournament_id)
  end
end