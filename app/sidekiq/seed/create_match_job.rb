class Seed::CreateMatchJob
  include Sidekiq::Job

  def perform(match_id)
    ThirdSeeder::CreateMatch.call(match_id)
  end
end
