class Seed::EnqueueTeamsCreationJob
  include Sidekiq::Job

  def perform(tournament_id)
    PandaScoreAPISeeder::EnqueueTeamsCreation.call(tournament_id)
  end
end
