class Seed::EnqueueTournamentsCreationJob
  include Sidekiq::Job

  def perform(serie_id)
    ThirdSeeder::EnqueueTournamentsCreation.call(serie_id)
  end
end
