class Seed::EnqueueTournamentsCreationJob
  include Sidekiq::Job

  def perform(serie_id)
    ApplicationSeeder::EnqueueTournamentsCreation.call(serie_id)
  end
end
