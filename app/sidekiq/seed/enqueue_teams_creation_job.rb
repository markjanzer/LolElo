class Seed::EnqueueTeamsCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    ThirdSeeder::EnqueueTeamsCreation.call(tournament_id)
  end
end
