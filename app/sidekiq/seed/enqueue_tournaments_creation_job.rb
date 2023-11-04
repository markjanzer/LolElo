class Seed::EnqueueTournamentsCreationJob
  include Sidekiq::Job

  def perform(serie_id)
    PandaScoreAPISeeder::EnqueueTournamentsCreation.call(serie_id)
  end
end
