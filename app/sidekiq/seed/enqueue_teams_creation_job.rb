class Seed::EnqueueTeamsCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    ApplicationSeeder::EnqueueTeamsCreation.call(tournament_id)
  end
end
