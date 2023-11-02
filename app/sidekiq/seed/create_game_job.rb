class Seed::CreateGameJob
  include Sidekiq::Job

  def perform(game_id)
    ThirdSeeder::CreateGame.call(game_id)
  end
end
