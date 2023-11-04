class Seed::CreateTeamJob
  include Sidekiq::Job

  def perform(team_id)
    PandaScoreAPISeeder::CreateTeam.call(team_id)
  end
end
