class Seed::CreateLeagueJob
  include Sidekiq::Job

  def perform(league_id)
    ApplicationSeeder::CreateLeague.call(league_id)
  end
end
