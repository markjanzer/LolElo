class Seed::CreateMatchAndGamesJob
  include Sidekiq::Job

  def perform(match_id)
    ApplicationSeeder::CreateMatchAndGames.call(match_id)
  end
end
