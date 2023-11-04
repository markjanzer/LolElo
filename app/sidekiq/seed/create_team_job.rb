class Seed::CreateTeamJob
  include Sidekiq::Job

  def perform(team_id)
    ApplicationSeeder::CreateTeam.call(team_id)
  end
end
