class Seed::CreateMatchAndGamesJob
  include Sidekiq::Job

  def perform(match_id)
    PandaScoreAPISeeder::CreateMatchAndGames.call(match_id)
  end
end
