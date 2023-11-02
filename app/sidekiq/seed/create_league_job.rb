class Seed::CreateLeagueJob
  include Sidekiq::Job

  def perform(league_id)
    ThirdSeeder::CreateLeague.call(league_id)
  end
end
