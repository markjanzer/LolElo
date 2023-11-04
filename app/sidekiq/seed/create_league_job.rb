class Seed::CreateLeagueJob
  include Sidekiq::Job

  def perform(league_id)
    PandaScoreAPISeeder::CreateLeague.call(league_id)
  end
end
