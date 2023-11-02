class Seed::CreateMatchAndGamesJob
  include Sidekiq::Job

  def perform(match_id)
    ThirdSeeder::CreateMatchAndGames.call(match_id)
  end
end
